#include <stdio.h>
#include <math.h>

#include <varg.h>
#include <mem.h>
#include <pbuf.h>
#include <ptable.h>



print_pbuf_dump(const pbuf_t *pbuf)
{
	static const char hex[16] = "0123456789abcdef";
	const int size = pbuf_size((pbuf_t*)pbuf);
	const char *p = pbuf_get((pbuf_t*)pbuf);
	const char *end = p+size;
	int pos = 0;
	int c;

	while (p < end) {
		c = (unsigned char)*p++;
		putchar(' ');
		putchar(hex[c >> 4]);
		putchar(hex[c & 0xf]);
		pos++;
		if (pos == 27) {
			putchar('\n');
			pos = 0;
		}
	}
	if (pos > 0)
		putchar('\n');
}

print_varg_dump(const varg_t *varg)
{
	pbuf_t *pbuf;

	pbuf = varg_format((varg_t*) varg);
	print_pbuf_dump(pbuf);
	pbuf_release(pbuf);
}


typedef const void* arg_value_container_t;

#define DEF_varg_set(varg_type, c_type) \
	int varg_set_##varg_type(varg_t *varg, int id, arg_value_container_t data) \
	{ \
		return varg_set(varg, id, VARG_##varg_type, (c_type)data); \
	}

DEF_varg_set(INT, int)
DEF_varg_set(BOOL, int)
DEF_varg_set(DATE, int)
DEF_varg_set(STRING, char *)
DEF_varg_set(CHAR, char)
DEF_varg_set(INT_TABLE, int *)
DEF_varg_set(STRING_TABLE, char **)
DEF_varg_set(ARG_TABLE, varg_t *)

int varg_set_REAL(varg_t *varg, int id, arg_value_container_t data)
{
	return varg_set(varg, id, VARG_REAL, *(double*)data);
}


int main(int argc, char **argv)
{
	static const double test_d0 = 0.0;
	static const double test_d1 = 1.0;
	static const double test_d2 = 1.5;
	static const double test_d3 = -1.0;
	static const double pi = M_PI;
	static const int test_int_table[] = { 0x482, 0x3288, 0x2, 0x44332211 };
	static const char const *test_str_table[] = { "Alpha", "Beta", "", "Gamma" };
	static char test_long_string[260];
	static const struct test {
		const char *name;
		unsigned int id;
		int (*varg_set_func)(varg_t*, int, const arg_value_container_t);
		const arg_value_container_t data;
    } tests[] = {
#define TEST(id, varg_type, value) { #varg_type " = " #value, id, varg_set_##varg_type, (arg_value_container_t)value }
        TEST(432, INT,       0),
        TEST(432, INT,       1),
        TEST(432, INT,     255),
        TEST(432, INT,     256),
        TEST(432, INT,  0xffff),
        TEST(432, INT, 0x10000),
        TEST(432, INT,      -1),
        TEST(432, INT, 0x7fffffff),
        TEST(432, INT, -0x7fffffff),
        TEST(0x1234, BOOL, FALSE),
        TEST(0x1234, BOOL, TRUE),
		TEST(0x4567, DATE, 1268831107),
		TEST(0x4568, DATE, 0x4ba0d383),
		/* REAL are transmitted as strings with 6 decimals: %.6f */
		{ "REAL = 0.0", 0x4567, varg_set_REAL, (arg_value_container_t)&test_d0 },
		{ "REAL = 1.0", 0x4567, varg_set_REAL, (arg_value_container_t)&test_d1 },
		{ "REAL = 1.5", 0x4567, varg_set_REAL, (arg_value_container_t)&test_d2 },
		{ "REAL = -1.0", 0x4567, varg_set_REAL, (arg_value_container_t)&test_d3 },
		{ "REAL = Pi", 0x4567, varg_set_REAL, (arg_value_container_t)&pi },
		TEST(0x1234, CHAR, 'a'),
		TEST(432, STRING, ""),
		TEST(432, STRING, "xx"),
	};
	static const char test_buf[] = "Toto1";

	varg_t *varg, *varg2;
	pbuf_t *pbuf, *pbuf_test;
	ptable_t *ptab;
	int i;
	int rc;

	mem_setchk(1);

#if 0
	puts("Pi:");
	pbuf = pbuf_build((char*)&pi, sizeof(pi));
	print_pbuf_dump(pbuf);
	pbuf_delete(pbuf);
#endif

	for(i=0; i<sizeof(tests)/sizeof(tests[0]); i++) {
		varg = varg_alloc();
		if ((rc = tests[i].varg_set_func(varg, tests[i].id, tests[i].data)) == 0) {
			printf("0x%x %s:\n", tests[i].id, tests[i].name);
			print_varg_dump(varg);
		} else {
			printf("0x%x %s:\n Err: %d\n", tests[i].id, varg_errno);
		}
		varg_free(varg);
	}


	/* Build the long string */
	for(i=0; i<sizeof(test_long_string)/sizeof(test_long_string[0])-2; i++)
		test_long_string[i] = 'A';
	test_long_string[sizeof(test_long_string)-2] = 'B';
	test_long_string[sizeof(test_long_string)-1] = '\0';

	printf("0x%x LONGSTRING (len=0x%x) :\n", 0x9876, strlen(test_long_string));
	varg = varg_alloc();
	varg_set(varg, 0x9876, VARG_STRING, test_long_string);
	print_varg_dump(varg);
	varg_free(varg);

	printf("0x%x BUFFER = \"%s\":\n", 0x1235, test_buf);
	pbuf_test = pbuf_build((char*)test_buf, sizeof(test_buf)-1);
	varg = varg_alloc();
	varg_set(varg, 0x1235, VARG_BUFFER, pbuf_test);
	print_varg_dump(varg);
	varg_free(varg);
	pbuf_delete(pbuf_test);

	printf("0x%x BUFFER = \"\":\n", 0x1235);
	pbuf_test = pbuf_build((char*)test_buf, 0);
	varg = varg_alloc();
	varg_set(varg, 0x1235, VARG_BUFFER, pbuf_test);
	print_varg_dump(varg);
	varg_free(varg);
	pbuf_delete(pbuf_test);

	printf("0x%x INT_TABLE = [ ]:\n", 0x1235);
	ptab = ptable_build(0, NULL);
	varg = varg_alloc();
	varg_setRef(varg, 0x1235, VARG_INT_TABLE, ptab);
	print_varg_dump(varg);
	varg_free(varg);

	printf("0x%x INT_TABLE = [ 0x%x, 0x%x, 0x%x, 0x%x ]:\n", 0x1235,
		test_int_table[0], test_int_table[1], test_int_table[2], test_int_table[3]);
	ptab = ptable_build(sizeof(test_int_table)/sizeof(test_int_table[0]), (int*)test_int_table);
	varg = varg_alloc();
	varg_set(varg, 0x1235, VARG_INT_TABLE, ptab);
	ptable_delete(ptab);
	print_varg_dump(varg);
	varg_free(varg);

	printf("0x%x STRING_TABLE = [ ]:\n", 0x1235,
		test_str_table[0], test_str_table[1], test_str_table[2]);
	ptab = ptable_build(0, NULL);
	varg = varg_alloc();
	varg_setRef(varg, 0x1235, VARG_STRING_TABLE, ptab);
	print_varg_dump(varg);
	varg_free(varg);

	printf("0x%x STRING_TABLE = [ \"%s\", \"%s\", \"%s\", \"%s\" ]:\n", 0x1235,
		test_str_table[0], test_str_table[1], test_str_table[2], test_str_table[3]);
	ptab = ptable_build(sizeof(test_str_table)/sizeof(test_str_table[0]), (char**)test_str_table);
	varg = varg_alloc();
	varg_set(varg, 0x1235, VARG_STRING_TABLE, ptab);
	ptable_delete(ptab);
	print_varg_dump(varg);
	varg_free(varg);

	printf("0x%x VARG_TABLE = [ ]:\n", 0x1235);
	ptab = ptable_build(0, NULL);
	varg = varg_alloc();
	varg_setRef(varg, 0x1235, VARG_ARG_TABLE, ptab);
	print_varg_dump(varg);
	varg_free(varg);

	printf("0x%x VARG_TABLE = [ { INT 0x8765 => 0x813 } ]:\n", 0x1235);
	ptab = ptable_build(0, NULL);
	varg2 = varg_alloc();
	varg_set(varg, 0x8765, VARG_INT, 0x813);
	ptable_add(&ptab, varg2); varg2 = NULL;
	varg = varg_alloc();
	varg_setRef(varg, 0x1235, VARG_ARG_TABLE, ptab);
	print_varg_dump(varg);
	varg_free(varg);

	printf("0x%x VARG_TABLE = [ { INT 0x8765 => 0x813, STRING 0x8777 => \"Toto\" }, { } ]:\n", 0x1235);
	ptab = ptable_build(0, NULL);
	varg2 = varg_alloc();
	varg_set(varg2, 0x8765, VARG_INT, 0x813);
	varg_set(varg2, 0x8777, VARG_STRING, "Toto");
	ptable_add(&ptab, varg2); varg2 = NULL;
	varg2 = varg_alloc();
	ptable_add(&ptab, varg2); varg2 = NULL;
	varg = varg_alloc();
	varg_setRef(varg, 0x1235, VARG_ARG_TABLE, ptab);
	print_varg_dump(varg);
	varg_free(varg);

	printf("0x%x VARG_TABLE = [ { INT 0x8765 => 0x813, STRING 0x8777 => \"Toto\" }, {  BOOL 0x1234 => TRUE } ]:\n", 0x1235);
	ptab = ptable_build(0, NULL);
	varg2 = varg_alloc();
	varg_set(varg2, 0x8765, VARG_INT, 0x813);
	varg_set(varg2, 0x8777, VARG_STRING, "Toto");
	ptable_add(&ptab, varg2); varg2 = NULL;
	varg2 = varg_alloc();
	varg_set(varg2, 0x1234, VARG_BOOL, TRUE);
	ptable_add(&ptab, varg2); varg2 = NULL;
	varg = varg_alloc();
	varg_setRef(varg, 0x1235, VARG_ARG_TABLE, ptab);
	print_varg_dump(varg);
	varg_free(varg);

	printf("0x%x VARG_TABLE = [ { INT 0x8765 => 0x813, STRING 0x8777 => \"Toto\" }, { }, { BOOL 0x1234 => TRUE } ]:\n", 0x1235);
	ptab = ptable_build(0, NULL);
	varg2 = varg_alloc();
	varg_set(varg2, 0x8765, VARG_INT, 0x813);
	varg_set(varg2, 0x8777, VARG_STRING, "Toto");
	ptable_add(&ptab, varg2); varg2 = NULL;
	varg2 = varg_alloc();
	ptable_add(&ptab, varg2); varg2 = NULL;
	varg2 = varg_alloc();
	varg_set(varg2, 0x1234, VARG_BOOL, TRUE);
	ptable_add(&ptab, varg2); varg2 = NULL;
	varg = varg_alloc();
	varg_setRef(varg, 0x1235, VARG_ARG_TABLE, ptab);
	print_varg_dump(varg);
	varg_free(varg);

	mem_report(0);

    return 0;
}

/* vim: set ts=4 sw=4 sts=4 : */
