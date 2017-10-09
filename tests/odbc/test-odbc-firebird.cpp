//
// Copyright (C) 2004-2006 Maciej Sobczak, Stephen Hutton, David Courtney
// Distributed under the Boost Software License, Version 1.0.
// (See accompanying file LICENSE_1_0.txt or copy at
// http://www.boost.org/LICENSE_1_0.txt)
//

#include "soci/soci.h"
#include "soci/odbc/soci-odbc.h"
#include <iostream>
#include <string>
#include <ctime>
#include <cmath>

#include "common-tests.h"

using namespace soci;
using namespace soci::tests;

// DDL Creation objects for common tests
struct table_creator_one : public table_creator_base
{
    table_creator_one(soci::session & sql)
        : table_creator_base(sql)
    {
        sql << "create table soci_test(id integer, val integer, c char, "
                 "str varchar(20), sh int2, ul numeric(20), d float8, "
                 "num76 numeric(7,6), "
                 "tm datetime, i1 integer, i2 integer, i3 integer, "
                 "name varchar(20)) engine=InnoDB";
    }
};

struct table_creator_two : public table_creator_base
{
    table_creator_two(soci::session & sql)
        : table_creator_base(sql)
    {
        sql  << "create table soci_test(num_float float8, num_int integer,"
                     " name varchar(20), sometime datetime, chr char)";
    }
};

struct table_creator_three : public table_creator_base
{
    table_creator_three(soci::session & sql)
        : table_creator_base(sql)
    {
        sql << "create table soci_test(name varchar(100) not null, "
            "phone varchar(15))";
    }
};

struct table_creator_for_get_affected_rows : table_creator_base
{
    table_creator_for_get_affected_rows(soci::session & sql)
        : table_creator_base(sql)
    {
        sql << "create table soci_test(val integer)";
    }
};

//
// Support for SOCI Common Tests
//

class test_context : public test_context_base
{
public:
    test_context(backend_factory const &backEnd,
                std::string const &connectString)
        : test_context_base(backEnd, connectString) {}

    table_creator_base* table_creator_1(soci::session& s) const SOCI_OVERRIDE
    {
        return new table_creator_one(s);
    }

    table_creator_base* table_creator_2(soci::session& s) const SOCI_OVERRIDE
    {
        return new table_creator_two(s);
    }

    table_creator_base* table_creator_3(soci::session& s) const SOCI_OVERRIDE
    {
        return new table_creator_three(s);
    }

    table_creator_base* table_creator_4(soci::session& s) const SOCI_OVERRIDE
    {
        return new table_creator_for_get_affected_rows(s);
    }

    std::string to_date_time(std::string const &datdt_string) const SOCI_OVERRIDE
    {
        return "\'" + datdt_string + "\'";
    }

    bool has_fp_bug() const SOCI_OVERRIDE
    {
        // MySQL fails in the common test3() with "1.8000000000000000 !=
        // 1.7999999999999998", so don't use exact doubles comparisons for it.
        return true;
    }

    bool has_transactions_support(soci::session& sql) const SOCI_OVERRIDE
    {
        sql << "drop table if exists soci_test";
        sql << "create table soci_test (id int) engine=InnoDB";
        row r;
        sql << "show table status like \'soci_test\'", into(r);
        bool retv = (r.get<std::string>(1) == "InnoDB");
        sql << "drop table soci_test";
        return retv;
    }

    bool has_silent_truncate_bug(soci::session& sql) const SOCI_OVERRIDE
    {
        std::string sql_mode;
        sql << "select @@session.sql_mode", into(sql_mode);

        // The database must be configured to use STRICT_{ALL,TRANS}_TABLES in
        // SQL mode to avoid silent truncation of too long values.
        return sql_mode.find("STRICT_") == std::string::npos;
    }

    bool enable_std_char_padding(session& sql) const SOCI_OVERRIDE
    {
        // turn on standard right padding on mysql. This options is supported as of version 5.1.20
        try
        {
            sql << "SET @@session.sql_mode = 'PAD_CHAR_TO_FULL_LENGTH'";
            return true;
        }
        catch(const soci_error&)
        {
            // Padding cannot be enabled - test will not be performed
            return false;
        }
    }

    std::string sql_length(std::string const& s) const SOCI_OVERRIDE
    {
        return "char_length(" + s + ")";
    }
};


std::string connectString;
backend_factory const &backEnd = *soci::factory_odbc();

int main(int argc, char** argv)
{
#ifdef _MSC_VER
    // Redirect errors, unrecoverable problems, and assert() failures to STDERR,
    // instead of debug message window.
    // This hack is required to run assert()-driven tests by Buildbot.
    // NOTE: Comment this 2 lines for debugging with Visual C++ debugger to catch assertions inside.
    _CrtSetReportMode(_CRT_ERROR, _CRTDBG_MODE_FILE);
    _CrtSetReportFile(_CRT_ERROR, _CRTDBG_FILE_STDERR);
#endif //_MSC_VER

    if (argc >= 2 && argv[1][0] != '-')
    {
        connectString = argv[1];

        // Replace the connect string with the process name to ensure that
        // CATCH uses the correct name in its messages.
        argv[1] = argv[0];

        argc--;
        argv++;
    }
    else
    {
        connectString = "FILEDSN=./test-firebird.dsn";
    }

    test_context tc(backEnd, connectString);

    return Catch::Session().run(argc, argv);
}
