from libc.stdint cimport *
cimport libc.string as ps
import numpy as np
cimport numpy as np

cdef extern from "stdlib.h":
    void *malloc(size_t size)
    void free(void *ptr)

cdef extern from "Python.h":
    int PyString_AsStringAndSize(object obj, char **buffer, Py_ssize_t *length) except -1



cdef extern from "capi.h":
    struct FastBitQueryHandle:
           pass
    struct FastBitQuery:
        pass
    struct FastBitResultSetHandle:
        pass
    struct FastBitResultSet:
        pass

cdef extern from *:
    ctypedef char* const_char_ptr "const char*"
    ctypedef FastBitResultSet* FastBitResultSetHandle "FastBitResultSet*"
    ctypedef FastBitQuery* FastBitQueryHandle "FastBitQuery*"


cdef extern from "capi.h":

    void     fastbit_init(char *rcfile)
    int      fastbit_add_values(char *colname, char *coltype, void *vals, uint32_t nelem, uint32_t start)

    int      fastbit_build_index (char *indexLocation, char *cname, char *indexOptions)
    int      fastbit_build_indexes (char *indexLocation, char *indexOptions)
    int      fastbit_purge_index(char *indexLocation, char *cname)
    int      fastbit_purge_indexes(char *indexLocation)

    void     fastbit_cleanup()
    int      fastbit_columns_in_partition (char *datadir)
    int      fastbit_rows_in_partition(char *datadir)
    int      fastbit_flush_buffer (char *datadir)
    char *   fastbit_get_logfile()
    int      fastbit_set_logfile(char *filename)
    int      fastbit_get_verbose_level()
    int      fastbit_set_verbose_level(int v)

    # Query class
    FastBitQuery *fastbit_build_query(char *selectClause, char *indexLocation, char *queryConditions)
    int      fastbit_destroy_query(FastBitQuery* query)
    int      fastbit_get_result_columns(FastBitQuery* query)
    int      fastbit_get_result_rows(FastBitQuery* query)
    char *   fastbit_get_select_clause(FastBitQuery* query)
    char *   fastbit_get_from_clause(FastBitQuery* query)
    char *   fastbit_get_where_clause(FastBitQuery* query)
    char *   fastbit_get_qualified_bytes (FastBitQuery* query, char *cname)
    double * fastbit_get_qualified_doubles (FastBitQuery* query, char *cname)
    float *  fastbit_get_qualified_floats (FastBitQuery* query, char *cname)
    int32_t * fastbit_get_qualified_ints (FastBitQuery* query, char *cname)
    int64_t * fastbit_get_qualified_longs (FastBitQuery* query, char *cname)
    int16_t * fastbit_get_qualified_shorts (FastBitQuery* query, char *cname)
    unsigned char *    fastbit_get_qualified_ubytes (FastBitQuery* query, char *cname)
    uint32_t *    fastbit_get_qualified_uints (FastBitQuery* query, char *cname)
    uint64_t *    fastbit_get_qualified_ulongs (FastBitQuery* query, char *cname)
    uint16_t *    fastbit_get_qualified_ushorts (FastBitQuery* query, const_char_ptr cname)


    #ctypedef char* const_char_ptr "const char*"
    # Result class
    FastBitResultSetHandle fastbit_build_result_set(FastBitQueryHandle query)
    int      fastbit_destroy_result_set(FastBitResultSetHandle rset)
    int      fastbit_result_set_next(FastBitResultSetHandle rset)
    double   fastbit_result_set_get_double(FastBitResultSetHandle rset, char *cname)
    float    fastbit_result_set_get_float(FastBitResultSetHandle rset, char *cname)
    int      fastbit_result_set_get_int(FastBitResultSetHandle rset, char *cname)
    char *   fastbit_result_set_get_string(FastBitResultSetHandle rset, char *cname)
    unsigned int fastbit_result_set_get_unsigned(FastBitResultSetHandle rset, char *cname)
    double   fastbit_result_set_getDouble(FastBitResultSetHandle rset, unsigned position)
    float    fastbit_result_set_getFloat(FastBitResultSetHandle rset, unsigned position)
    int32_t  fastbit_result_set_getInt(FastBitResultSetHandle rset, unsigned position)
    char *   fastbit_result_set_getString(FastBitResultSetHandle rset, unsigned position)
    uint32_t fastbit_result_set_getUnsigned(FastBitResultSetHandle rset, unsigned position)

