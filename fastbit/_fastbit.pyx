import numpy as np


_dtype_to_fastbit = {
     'H': 'us', # uint16
     'L': 'ui', # uint32
     'Q': 'ul', # uint64
     'S': 'b',  # string
     'c': 'b',  # byte
     'b': 'ub', # ubyte
     'f': 'f',  # float
     'h': 's',  # int16
     'l': 'i',  # int32
     'i': 'i',  # int64
     'q': 'l',  # int64
     'd': 'f',  # float/double
}

_fastbit_to_dtype = dict((v, k) for k, v in _dtype_to_fastbit.items())

cdef class FastBit:
    cdef readonly datadir
    cdef readonly col_types

    def __init__(self, datadir=None):
        self.col_types = None

        if datadir:
            fastbit_init(datadir)
            self.datadir = datadir
        else:
            fastbit_init(NULL)

    def query(self, condition, *columns):
        self.flush_buffer()
        q = Query(self.datadir, condition, self, *columns)
        return q

    def __del__(self):
        print "cleaning"
        self.cleanup()

    def add_array(self, np.ndarray array, colname, int start=0):
        #cdef np.ndarray[int, ndim=1] array = np.asarray(arr)
        cdef int n = array.shape[0]
        fastbit_code = _dtype_to_fastbit[array.dtype.char]
        fastbit_add_values(colname, fastbit_code, array.data, n, start)
        self.col_types = None


    @classmethod
    def build_index(cls, datadir, colname, options):
        return fastbit_build_index(datadir,  colname, options)

    @classmethod
    def build_indexes(cls, datadir, options):
        return fastbit_build_indexes(datadir, options)

    @classmethod
    def purge_index(self, datadir, colname):
        return fastbit_purge_index(datadir, colname)

    @classmethod
    def purge_indexes(self, datadir):
        return fastbit_purge_indexes(datadir)

    def cleanup(self):
        fastbit_cleanup()

    def columns_in_partition(self, datadir):
        return fastbit_columns_in_partition(datadir)

    def rows_in_partition(self, datadir):
        return fastbit_rows_in_partition(datadir)

    def flush_buffer(self, datadir=None):
        if datadir is None:
            datadir = self.datadir
        return fastbit_flush_buffer(datadir)

    def _get_logfile(self):
        return fastbit_get_logfile()

    def _set_logfile(self, filename):
        return fastbit_set_logfile(filename)

    logfile = property(_get_logfile, _set_logfile)

    def _get_verbose_level(self):
        return fastbit_get_verbose_level()

    def _set_verbose_level(self, v):
        return fastbit_set_verbose_level(v)

    verbosity = property(_get_verbose_level, _set_verbose_level)

    def guess_col_types(self, datadir=None):
        if self.col_types is not None: return self.col_types
        f = open('%s/-part.txt' % self.datadir).read()
        cols = [x.strip() for x in f.split('Begin Column')[1:]]
        cols = [x.split("\n")[:-1] for x in cols]

        d = {}
        for col in cols:
            assert len(col) == 2, col
            colname = col[0].split("=")[1].strip()
            colval = col[1].split("=")[1].strip()
            d[colname] = colval[0].lower()

        self.col_types = d
        return d

cdef class Query:
    cdef FastBitQuery *qh
    cdef readonly columns
    cdef readonly ftypes

    def __init__(self, datadir, query, fastbit, *_columns):
        self.ftypes = fastbit.guess_col_types()
        if not _columns:
            _columns = self.ftypes.keys()
        self.columns = _columns
        columns = ",".join(_columns)
        self.qh = fastbit_build_query(columns, datadir, query)

    def __del__(self):
        print "called destroy", self
        self.destroy_query()

    def __repr__(self):
        select = self.get_select_clause()
        if select.strip() == '': select = 'count(*)'
        from_clause = self.get_from_clause()
        where = self.get_where_clause()
        return 'Query(SELECT "%s" FROM "%s" WHERE (%s))' % (select, from_clause, where)

    def __len__(self): return self.nrows

    def __getattr__(self, colname):
        ftype = self.ftypes[colname]
        if ftype == 'i':
            return self.get_qualified_ints(colname)
        if ftype == 'l':
            return self.get_qualified_longs(colname)
        elif ftype in 'f':
            return self.get_qualified_floats(colname)

    def __getitem__(self, colname):
        return getattr(self, colname)

    def destroy_query(self):
        fastbit_destroy_query(self.qh)

    def get_from_clause(self):
        return fastbit_get_from_clause(self.qh)

    def get_where_clause(self):
        return fastbit_get_where_clause(self.qh)

    def _get_result_columns(self):
        return fastbit_get_result_columns(self.qh)
    ncolumns = property(_get_result_columns)

    def _get_result_rows(self):
        return fastbit_get_result_rows(self.qh)
    nrows = property(_get_result_rows)

    def get_select_clause(self):
        return fastbit_get_select_clause (self.qh)

    def destroy_query(self):
        fastbit_destroy_query(self.qh)

    def get_from_clause(self):
        return fastbit_get_from_clause(self.qh)

    def get_where_clause(self):
        return fastbit_get_where_clause(self.qh)

    def _get_result_rows(self):
        return fastbit_get_result_rows(self.qh)
    rows = property(_get_result_rows)

    def get_select_clause(self):
        return fastbit_get_select_clause (self.qh)

    def get_qualified_bytes(self, cname):
        cdef char *d = fastbit_get_qualified_bytes(self.qh, cname)
        cdef int i, rows = fastbit_get_result_rows(self.qh)
        return [d[i] for i in range(rows)]

    def get_qualified_doubles(self, cname):
        cdef double *d = fastbit_get_qualified_doubles(self.qh, cname)
        cdef int rows = fastbit_get_result_rows(self.qh)
        return [v for v in d[:rows]]


    cdef get_qualified_floats(self, cname):
        cdef float *d = fastbit_get_qualified_floats(self.qh, cname)
        cdef int rows = fastbit_get_result_rows(self.qh)
        return [v for v in d[:rows]]

    cdef get_qualified_ints(self, cname):
        cdef int32_t *d = fastbit_get_qualified_ints(self.qh, cname)
        cdef int rows = fastbit_get_result_rows(self.qh)
        return [v for v in d[:rows]]

    def get_qualified_longs(self, cname):
        cdef int64_t *d = fastbit_get_qualified_longs(self.qh, cname)
        cdef int rows = fastbit_get_result_rows(self.qh)
        return [v for v in d[:rows]]

    def get_qualified_shorts(self, cname):
        cdef int16_t *d = fastbit_get_qualified_shorts(self.qh, cname)
        cdef int i, rows = fastbit_get_result_rows(self.qh)
        return [d[i] for i in range(rows)]

    def get_qualified_ubytes(self, cname):
        cdef unsigned char *d = fastbit_get_qualified_ubytes(<FastBitQuery*>(self.qh),<char *>cname)
        cdef int i, rows = fastbit_get_result_rows(self.qh)
        return [d[i] for i in range(rows)]

    def get_qualified_uints(self, cname):
        cdef uint32_t *d = fastbit_get_qualified_uints(self.qh, cname)
        cdef int i, rows = fastbit_get_result_rows(self.qh)
        return [d[i] for i in range(rows)]

    def get_qualified_ulongs(self, cname):
        cdef uint64_t *d = fastbit_get_qualified_ulongs(self.qh, cname)
        cdef int i, rows = fastbit_get_result_rows(self.qh)
        return [d[i] for i in range(rows)]

    def get_qualified_ushorts(self, cname):
        cdef uint16_t *d = fastbit_get_qualified_ushorts(self.qh, <const_char_ptr>cname)
        cdef int i, rows = fastbit_get_result_rows(self.qh)
        return [d[i] for i in range(rows)]
