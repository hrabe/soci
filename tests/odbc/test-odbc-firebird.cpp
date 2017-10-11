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

#define SOCI_POSTGRESQL_NOPARAMS
#include "common-tests.h"

using namespace soci;
using namespace soci::tests;

//
// Support for soci Common Tests
//

struct TableCreator1 : public tests::table_creator_base
{
    TableCreator1(soci::session & sql)
            : tests::table_creator_base(sql)
    {
        sql << "create table soci_test(id integer, val integer, c char, "
        "str varchar(20), sh smallint, ul bigint, d double precision, "
        "num76 numeric(7,6), "
        "tm timestamp, i1 integer, i2 integer, i3 integer, name varchar(20))";
//        sql.commit();
//        sql.begin();
    }
};

struct TableCreator2 : public tests::table_creator_base
{
    TableCreator2(soci::session & sql)
            : tests::table_creator_base(sql)
    {
        sql  << "create table soci_test(num_float float, num_int integer, "
        "name varchar(20), sometime timestamp, chr char)";
//        sql.commit();
//        sql.begin();
    }
};

struct TableCreator3 : public tests::table_creator_base
{
    TableCreator3(soci::session & sql)
            : tests::table_creator_base(sql)
    {
        sql << "create table soci_test(name varchar(100) not null, "
        "phone varchar(15))";
//        sql.commit();
//        sql.begin();
    }
};

struct TableCreator4 : public tests::table_creator_base
{
    TableCreator4(soci::session & sql)
            : tests::table_creator_base(sql)
    {
        sql << "create table soci_test(val integer)";
//        sql.commit();
//        sql.begin();
    }
};

struct TableCreatorCLOB : public tests::table_creator_base
{
    TableCreatorCLOB(soci::session & sql)
            : tests::table_creator_base(sql)
    {
        sql << "create table soci_test(id integer, s blob sub_type text)";
//        sql.commit();
//        sql.begin();
    }
};

struct TableCreatorXML : public tests::table_creator_base
{
    TableCreatorXML(soci::session & sql)
            : tests::table_creator_base(sql)
    {
        sql << "create table soci_test(id integer, x blob sub_type text)";
//        sql.commit();
//        sql.begin();
    }
};

class test_context : public tests::test_context_base
{
    public:
        test_context(backend_factory const &backEnd,
                    std::string const &connectString)
                : test_context_base(backEnd, connectString)
        {}

        tests::table_creator_base* table_creator_1(soci::session& s) const SOCI_OVERRIDE
        {
            return new TableCreator1(s);
        }

        tests::table_creator_base* table_creator_2(soci::session& s) const SOCI_OVERRIDE
        {
            return new TableCreator2(s);
        }

        tests::table_creator_base* table_creator_3(soci::session& s) const SOCI_OVERRIDE
        {
            return new TableCreator3(s);
        }

        tests::table_creator_base* table_creator_4(soci::session& s) const SOCI_OVERRIDE
        {
            return new TableCreator4(s);
        }

        bool has_multiple_select_bug() const SOCI_OVERRIDE
        { 
            return true; 
        }

        std::string to_date_time(std::string const &datdt_string) const SOCI_OVERRIDE
        {
            return "'" + datdt_string + "'";
        }

        bool has_silent_truncate_bug(session&) const SOCI_OVERRIDE
        {
            return true;
        }
        
        virtual bool enable_std_char_padding(session&) const SOCI_OVERRIDE { 
            return false; 
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
