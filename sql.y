%{

package main

%}

%union {
  sqlSelect *SelectStmt
  fields []Expr
  expr Expr
  str string
  identifiers []string
  fromClause *FromClause
  whereClause *WhereClause
  orderExpr OrderExpr
  orderClause *OrderClause
  groupByClause *GroupByClause
  limitClause *LimitClause
  lockingClause *LockingClause
  lockingItem LockingItem
  boolean bool
  placeholder interface{}
  columnRef ColumnRef
}

%type <sqlSelect> top
%type <sqlSelect> SelectStmt
%type <sqlSelect> select_no_parens
%type <sqlSelect> select_with_parens select_clause simple_select
%type <fields> opt_target_list target_list distinct_clause expr_list
%type <placeholder> opt_all_clause

%type <expr> aliasableExpr
%type <expr> expr target_el a_expr c_expr
%type <fromClause> from_clause
%type <identifiers> identifierSeq
%type <expr> joinExpr
%type <whereClause> where_clause
%type <orderExpr> sortby
%type <orderClause> opt_sort_clause sort_clause sortby_list
%type <str> opt_asc_desc opt_nulls_order
%type <placeholder> into_clause
  window_clause
  values_clause
  relation_expr


%type <limitClause> select_limit opt_select_limit

%type <expr> limit_clause offset_clause select_limit_value select_offset_value

%type <lockingClause> opt_for_locking_clause for_locking_clause for_locking_items
%type <lockingItem> for_locking_item
%type <str> for_locking_strength opt_nowait_or_skip

%type <identifiers> locked_rels_list qualified_name_list indirection name_list

%type <str> indirection_el attr_name qualified_name ColId name

%type <str> MathOp qual_Op qual_all_Op all_Op

%type <groupByClause> group_clause
%type <fields>  group_by_list
%type <expr> group_by_item

%type <expr> having_clause

%type <boolean> all_or_distinct

%type <str>  Iconst SignedIconst Sconst

%type <columnRef> columnref

%type <str>
  ColLabel
  unreserved_keyword
  col_name_keyword
  type_func_name_keyword
  reserved_keyword



%token  <str> OP any_operator


/*
 * Non-keyword token types.  These are hard-wired into the "flex" lexer.
 * They must be listed first so that their numeric codes do not depend on
 * the set of keywords.  PL/pgsql depends on this so that it can share the
 * same lexer.  If you add/change tokens here, fix PL/pgsql to match!
 *
 * DOT_DOT is unused in the core SQL grammar, and so will always provoke
 * parse errors.  It is needed by PL/pgsql.
 */
%token <str>  IDENT FCONST SCONST BCONST XCONST Op
/* ival in PostgreSQL */
%token <str> ICONST PARAM
%token      TYPECAST DOT_DOT COLON_EQUALS EQUALS_GREATER
%token      LESS_EQUALS GREATER_EQUALS NOT_EQUALS


/* ordinary key words in alphabetical order */
%token <str> ABORT_P ABSOLUTE_P ACCESS ACTION ADD_P ADMIN AFTER
  AGGREGATE ALL ALSO ALTER ALWAYS ANALYSE ANALYZE AND ANY ARRAY AS ASC
  ASSERTION ASSIGNMENT ASYMMETRIC AT ATTRIBUTE AUTHORIZATION

  BACKWARD BEFORE BEGIN_P BETWEEN BIGINT BINARY BIT
  BOOLEAN_P BOTH BY

  CACHE CALLED CASCADE CASCADED CASE CAST CATALOG_P CHAIN CHAR_P
  CHARACTER CHARACTERISTICS CHECK CHECKPOINT CLASS CLOSE
  CLUSTER COALESCE COLLATE COLLATION COLUMN COMMENT COMMENTS COMMIT
  COMMITTED CONCURRENTLY CONFIGURATION CONFLICT CONNECTION CONSTRAINT
  CONSTRAINTS CONTENT_P CONTINUE_P CONVERSION_P COPY COST CREATE
  CROSS CSV CUBE CURRENT_P
  CURRENT_CATALOG CURRENT_DATE CURRENT_ROLE CURRENT_SCHEMA
  CURRENT_TIME CURRENT_TIMESTAMP CURRENT_USER CURSOR CYCLE

  DATA_P DATABASE DAY_P DEALLOCATE DEC DECIMAL_P DECLARE DEFAULT DEFAULTS
  DEFERRABLE DEFERRED DEFINER DELETE_P DELIMITER DELIMITERS DESC
  DICTIONARY DISABLE_P DISCARD DISTINCT DO DOCUMENT_P DOMAIN_P DOUBLE_P DROP

  EACH ELSE ENABLE_P ENCODING ENCRYPTED END_P ENUM_P ESCAPE EVENT EXCEPT
  EXCLUDE EXCLUDING EXCLUSIVE EXECUTE EXISTS EXPLAIN
  EXTENSION EXTERNAL EXTRACT

  FALSE_P FAMILY FETCH FILTER FIRST_P FLOAT_P FOLLOWING FOR
  FORCE FOREIGN FORWARD FREEZE FROM FULL FUNCTION FUNCTIONS

  GLOBAL GRANT GRANTED GREATEST GROUP_P GROUPING

  HANDLER HAVING HEADER_P HOLD HOUR_P

  IDENTITY_P IF_P ILIKE IMMEDIATE IMMUTABLE IMPLICIT_P IMPORT_P IN_P
  INCLUDING INCREMENT INDEX INDEXES INHERIT INHERITS INITIALLY INLINE_P
  INNER_P INOUT INPUT_P INSENSITIVE INSERT INSTEAD INT_P INTEGER
  INTERSECT INTERVAL INTO INVOKER IS ISNULL ISOLATION

  JOIN

  KEY

  LABEL LANGUAGE LARGE_P LAST_P LATERAL_P
  LEADING LEAKPROOF LEAST LEFT LEVEL LIKE LIMIT LISTEN LOAD LOCAL
  LOCALTIME LOCALTIMESTAMP LOCATION LOCK_P LOCKED LOGGED

  MAPPING MATCH MATERIALIZED MAXVALUE MINUTE_P MINVALUE MODE MONTH_P MOVE

  NAME_P NAMES NATIONAL NATURAL NCHAR NEXT NO NONE
  NOT NOTHING NOTIFY NOTNULL NOWAIT NULL_P NULLIF
  NULLS_P NUMERIC

  OBJECT_P OF OFF OFFSET OIDS ON ONLY OPERATOR OPTION OPTIONS OR
  ORDER ORDINALITY OUT_P OUTER_P OVER OVERLAPS OVERLAY OWNED OWNER

  PARSER PARTIAL PARTITION PASSING PASSWORD PLACING PLANS POLICY POSITION
  PRECEDING PRECISION PRESERVE PREPARE PREPARED PRIMARY
  PRIOR PRIVILEGES PROCEDURAL PROCEDURE PROGRAM

  QUOTE

  RANGE READ REAL REASSIGN RECHECK RECURSIVE REF REFERENCES REFRESH REINDEX
  RELATIVE_P RELEASE RENAME REPEATABLE REPLACE REPLICA
  RESET RESTART RESTRICT RETURNING RETURNS REVOKE RIGHT ROLE ROLLBACK ROLLUP
  ROW ROWS RULE

  SAVEPOINT SCHEMA SCROLL SEARCH SECOND_P SECURITY SELECT SEQUENCE SEQUENCES
  SERIALIZABLE SERVER SESSION SESSION_USER SET SETS SETOF SHARE SHOW
  SIMILAR SIMPLE SKIP SMALLINT SNAPSHOT SOME SQL_P STABLE STANDALONE_P START
  STATEMENT STATISTICS STDIN STDOUT STORAGE STRICT_P STRIP_P SUBSTRING
  SYMMETRIC SYSID SYSTEM_P

  TABLE TABLES TABLESAMPLE TABLESPACE TEMP TEMPLATE TEMPORARY TEXT_P THEN
  TIME TIMESTAMP TO TRAILING TRANSACTION TRANSFORM TREAT TRIGGER TRIM TRUE_P
  TRUNCATE TRUSTED TYPE_P TYPES_P

  UNBOUNDED UNCOMMITTED UNENCRYPTED UNION UNIQUE UNKNOWN UNLISTEN UNLOGGED
  UNTIL UPDATE USER USING

  VACUUM VALID VALIDATE VALIDATOR VALUE_P VALUES VARCHAR VARIADIC VARYING
  VERBOSE VERSION_P VIEW VIEWS VOLATILE

  WHEN WHERE WHITESPACE_P WINDOW WITH WITHIN WITHOUT WORK WRAPPER WRITE

  XML_P XMLATTRIBUTES XMLCONCAT XMLELEMENT XMLEXISTS XMLFOREST XMLPARSE
  XMLPI XMLROOT XMLSERIALIZE

  YEAR_P YES_P

  ZONE

/*
 * The grammar thinks these are keywords, but they are not in the kwlist.h
 * list and so can never be entered directly.  The filter in parser.c
 * creates these tokens when required (based on looking one token ahead).
 *
 * NOT_LA exists so that productions such as NOT LIKE can be given the same
 * precedence as LIKE; otherwise they'd effectively have the same precedence
 * as NOT, at least with respect to their left-hand subexpression.
 * NULLS_LA and WITH_LA are needed to make the grammar LALR(1).
 */
%token    NOT_LA NULLS_LA WITH_LA

%left OP


/* Precedence: lowest to highest */
%nonassoc SET       /* see relation_expr_opt_alias */
%left   UNION EXCEPT
%left   INTERSECT
%left   OR
%left   AND
%right    NOT
%nonassoc IS ISNULL NOTNULL /* IS sets precedence for IS NULL, etc */
%nonassoc '<' '>' '=' LESS_EQUALS GREATER_EQUALS NOT_EQUALS
%nonassoc BETWEEN IN_P LIKE ILIKE SIMILAR NOT_LA
%nonassoc ESCAPE      /* ESCAPE must be just above LIKE/ILIKE/SIMILAR */
%nonassoc OVERLAPS
%left   POSTFIXOP   /* dummy for postfix Op rules */
/*
 * To support target_el without AS, we must give IDENT an explicit priority
 * between POSTFIXOP and Op.  We can safely assign the same priority to
 * various unreserved keywords as needed to resolve ambiguities (this can't
 * have any bad effects since obviously the keywords will still behave the
 * same as if they weren't keywords).  We need to do this for PARTITION,
 * RANGE, ROWS to support opt_existing_window_name; and for RANGE, ROWS
 * so that they can follow a_expr without creating postfix-operator problems;
 * and for NULL so that it can follow b_expr in ColQualList without creating
 * postfix-operator problems.
 *
 * To support CUBE and ROLLUP in GROUP BY without reserving them, we give them
 * an explicit priority lower than '(', so that a rule with CUBE '(' will shift
 * rather than reducing a conflicting rule that takes CUBE as a function name.
 * Using the same precedence as IDENT seems right for the reasons given above.
 *
 * The frame_bound productions UNBOUNDED PRECEDING and UNBOUNDED FOLLOWING
 * are even messier: since UNBOUNDED is an unreserved keyword (per spec!),
 * there is no principled way to distinguish these from the productions
 * a_expr PRECEDING/FOLLOWING.  We hack this up by giving UNBOUNDED slightly
 * lower precedence than PRECEDING and FOLLOWING.  At present this doesn't
 * appear to cause UNBOUNDED to be treated differently from other unreserved
 * keywords anywhere else in the grammar, but it's definitely risky.  We can
 * blame any funny behavior of UNBOUNDED on the SQL standard, though.
 */
%nonassoc UNBOUNDED   /* ideally should have same precedence as IDENT */
%nonassoc IDENT NULL_P PARTITION RANGE ROWS PRECEDING FOLLOWING CUBE ROLLUP
%left   Op OPERATOR   /* multi-character ops and user-defined operators */
%left   '+' '-'
%left   '*' '/' '%'
%left   '^'
/* Unary Operators */
%left   AT        /* sets precedence for AT TIME ZONE */
%left   COLLATE
%right    UMINUS
%left   '[' ']'
%left   '(' ')'
%left   TYPECAST
%left   '.'
/*
 * These might seem to be low-precedence, but actually they are not part
 * of the arithmetic hierarchy at all in their use as JOIN operators.
 * We make them high-precedence to support their use as function names.
 * They wouldn't be given a precedence at all, were it not that we need
 * left-associativity among the JOIN rules themselves.
 */
%left   JOIN CROSS LEFT FULL RIGHT INNER_P NATURAL
/* kluge to keep xml_whitespace_option from causing shift/reduce conflicts */
%right    PRESERVE STRIP_P


%%

top:
  SelectStmt
  {
    $$ = $1
    sqllex.(*sqlLex).stmt = $1
  }

opt_asc_desc:
  ASC          { $$ = "asc" }
| DESC         { $$ = "desc" }
| /*EMPTY*/    { $$ = "" }

opt_nulls_order:
  NULLS_LA FIRST_P    { $$ = "first" }
| NULLS_LA LAST_P     { $$ = "last" }
| /*EMPTY*/           { $$ = "" }

aliasableExpr:
  expr
  {
    $$ = $1
  }
| expr AS IDENT
  {
    $$ = AliasedExpr{Expr: $1, Alias: $3}
  }
| expr IDENT
  {
    $$ = AliasedExpr{Expr: $1, Alias: $2}
  }

expr:
  c_expr { $$ = $1 }
| Sconst
  {
    $$ = StringLiteral($1)
  }
| Iconst
  {
    $$ = IntegerLiteral($1)
  }
| TRUE_P /* temp hack while integrating PostgreSQL keywords */
  {
    $$ = ColumnRef{Column: "true"}
  }
| expr '+' expr
  {
    $$ = BinaryExpr{Left: $1, Operator: "+", Right: $3}
  }
| expr '-' expr
  {
    $$ = BinaryExpr{Left: $1, Operator: "-", Right: $3}
  }
| expr '*' expr
  {
    $$ = BinaryExpr{Left: $1, Operator: "*", Right: $3}
  }
| expr '/' expr
  {
    $$ = BinaryExpr{Left: $1, Operator: "/", Right: $3}
  }
| expr '=' expr
  {
    $$ = BinaryExpr{Left: $1, Operator: "=", Right: $3}
  }
| expr '<' expr
  {
    $$ = BinaryExpr{Left: $1, Operator: "<", Right: $3}
  }
| expr '>' expr
  {
    $$ = BinaryExpr{Left: $1, Operator: ">", Right: $3}
  }
| expr OP expr
  {
    $$ = BinaryExpr{Left: $1, Operator: $2, Right: $3}
  }
| expr AND expr
  {
    $$ = BinaryExpr{Left: $1, Operator: "and", Right: $3}
  }
| expr OR expr
  {
    $$ = BinaryExpr{Left: $1, Operator: "or", Right: $3}
  }
| NOT expr
  {
    $$ = NotExpr{Expr: $2}
  }
| '(' expr ')'
  {
    $$ = ParenExpr{Expr: $2}
  }
| '(' SelectStmt ')'
  {
    $$ = ParenExpr{Expr: $2}
  }

a_expr: expr


/*
 * Productions that can be used in both a_expr and b_expr.
 *
 * Note: productions that refer recursively to a_expr or b_expr mostly
 * cannot appear here.  However, it's OK to refer to a_exprs that occur
 * inside parentheses, such as function arguments; that cannot introduce
 * ambiguity to the b_expr syntax.
 */
c_expr:
  columnref { $$ = $1 }

identifierSeq:
  IDENT
  {
    $$ = []string{$1}
  }
| identifierSeq ',' IDENT
  {
    $$ = append($1, $3)
  }

joinExpr:
  aliasableExpr ',' aliasableExpr
  {
    $$ = JoinExpr{Left: $1, Join: ",", Right: $3}
  }
| aliasableExpr CROSS JOIN aliasableExpr
  {
    $$ = JoinExpr{Left: $1, Join: "cross join", Right: $4}
  }
| aliasableExpr NATURAL JOIN aliasableExpr
  {
    $$ = JoinExpr{Left: $1, Join: "natural join", Right: $4}
  }
| aliasableExpr JOIN aliasableExpr USING '(' identifierSeq ')'
  {
    $$ = JoinExpr{Left: $1, Join: "join", Right: $3, Using: $6}
  }
| aliasableExpr JOIN aliasableExpr ON expr
  {
    $$ = JoinExpr{Left: $1, Join: "join", Right: $3, On: $5}
  }

from_clause:
  FROM aliasableExpr
  {
    $$ = &FromClause{Expr: $2}
  }
| FROM joinExpr
  {
    $$ = &FromClause{Expr: $2}
  }
| /*EMPTY*/  { $$ = nil }


opt_nowait_or_skip:
  NOWAIT        { $$ = "nowait" }
| SKIP LOCKED   { $$ = "skip locked" }
| /*EMPTY*/     { $$ = "" }


expr_list:
  a_expr
  {
    $$ = []Expr{$1}
  }
| expr_list ',' a_expr
  {
    $$ = append($1, $3)
  }


/*****************************************************************************
 *
 *    QUERY:
 *        SELECT STATEMENTS
 *
 *****************************************************************************/

/* A complete SELECT statement looks like this.
 *
 * The rule returns either a single SelectStmt node or a tree of them,
 * representing a set-operation tree.
 *
 * There is an ambiguity when a sub-SELECT is within an a_expr and there
 * are excess parentheses: do the parentheses belong to the sub-SELECT or
 * to the surrounding a_expr?  We don't really care, but bison wants to know.
 * To resolve the ambiguity, we are careful to define the grammar so that
 * the decision is staved off as long as possible: as long as we can keep
 * absorbing parentheses into the sub-SELECT, we will do so, and only when
 * it's no longer possible to do that will we decide that parens belong to
 * the expression.  For example, in "SELECT (((SELECT 2)) + 3)" the extra
 * parentheses are treated as part of the sub-select.  The necessity of doing
 * it that way is shown by "SELECT (((SELECT 2)) UNION SELECT 2)".  Had we
 * parsed "((SELECT 2))" as an a_expr, it'd be too late to go back to the
 * SELECT viewpoint when we see the UNION.
 *
 * This approach is implemented by defining a nonterminal select_with_parens,
 * which represents a SELECT with at least one outer layer of parentheses,
 * and being careful to use select_with_parens, never '(' SelectStmt ')',
 * in the expression grammar.  We will then have shift-reduce conflicts
 * which we can resolve in favor of always treating '(' <select> ')' as
 * a select_with_parens.  To resolve the conflicts, the productions that
 * conflict with the select_with_parens productions are manually given
 * precedences lower than the precedence of ')', thereby ensuring that we
 * shift ')' (and then reduce to select_with_parens) rather than trying to
 * reduce the inner <select> nonterminal to something else.  We use UMINUS
 * precedence for this, which is a fairly arbitrary choice.
 *
 * To be able to define select_with_parens itself without ambiguity, we need
 * a nonterminal select_no_parens that represents a SELECT structure with no
 * outermost parentheses.  This is a little bit tedious, but it works.
 *
 * In non-expression contexts, we use SelectStmt which can represent a SELECT
 * with or without outer parentheses.
 */

SelectStmt:
  select_no_parens   %prec UMINUS
| select_with_parens %prec UMINUS


select_with_parens:
  '(' select_no_parens ')'        { $$ = $2 }
| '(' select_with_parens ')'      { $$ = $2 }

select_no_parens:
  simple_select
| select_clause sort_clause
  {
    $1.OrderClause = $2
    $$ = $1
  }
| select_clause opt_sort_clause for_locking_clause opt_select_limit
  {
    $1.OrderClause = $2
    $1.LockingClause = $3
    $1.LimitClause = $4
    $$ = $1;
  }
| select_clause opt_sort_clause select_limit opt_for_locking_clause
  {
    $1.OrderClause = $2
    $1.LimitClause = $3
    $1.LockingClause = $4
    $$ = $1;
  }

select_clause:
  simple_select
| select_with_parens

/*
 * This rule parses SELECT statements that can appear within set operations,
 * including UNION, INTERSECT and EXCEPT.  '(' and ')' can be used to specify
 * the ordering of the set operations.  Without '(' and ')' we want the
 * operations to be ordered per the precedence specs at the head of this file.
 *
 * As with select_no_parens, simple_select cannot have outer parentheses,
 * but can have parenthesized subclauses.
 *
 * Note that sort clauses cannot be included at this level --- SQL requires
 *    SELECT foo UNION SELECT bar ORDER BY baz
 * to be parsed as
 *    (SELECT foo UNION SELECT bar) ORDER BY baz
 * not
 *    SELECT foo UNION (SELECT bar ORDER BY baz)
 * Likewise for WITH, FOR UPDATE and LIMIT.  Therefore, those clauses are
 * described as part of the select_no_parens production, not simple_select.
 * This does not limit functionality, because you can reintroduce these
 * clauses inside parentheses.
 *
 * NOTE: only the leftmost component SelectStmt should have INTO.
 * However, this is not checked by the grammar; parse analysis must check it.
 */
simple_select:
      SELECT opt_all_clause opt_target_list
      into_clause from_clause where_clause
      group_clause having_clause window_clause
        {
          ss := &SelectStmt{}
          ss.TargetList = $3
          ss.FromClause = $5
          ss.WhereClause = $6
          ss.GroupByClause = $7
          ss.HavingClause = $8
          $$ = ss
        }
      | SELECT distinct_clause target_list
      into_clause from_clause where_clause
      group_clause having_clause window_clause
        {
          ss := &SelectStmt{}
          ss.DistinctList = $2
          ss.TargetList = $3
          ss.FromClause = $5
          ss.WhereClause = $6
          ss.GroupByClause = $7
          ss.HavingClause = $8
          $$ = ss
        }
/*      | values_clause
      | TABLE relation_expr
        {
          panic("TODO")
        }
      | select_clause UNION all_or_distinct select_clause
        {
          panic("TODO")
        }
      | select_clause INTERSECT all_or_distinct select_clause
        {
          panic("TODO")
        }
      | select_clause EXCEPT all_or_distinct select_clause
        {
          panic("TODO")
        }
*/



into_clause:
/* TODO      INTO OptTempTableName
        {
          $$ = makeNode(IntoClause);
          $$->rel = $2;
          $$->colNames = NIL;
          $$->options = NIL;
          $$->onCommit = ONCOMMIT_NOOP;
          $$->tableSpaceName = NULL;
          $$->viewQuery = NULL;
          $$->skipData = false;
        }
      | */ /*EMPTY*/
        { $$ = nil }



all_or_distinct:
  ALL                   { $$ = true }
      | DISTINCT                { $$ = false }
      | /*EMPTY*/               { $$ = false }
    ;


distinct_clause:
  DISTINCT { $$ = make([]Expr, 0) }
| DISTINCT ON '(' expr_list ')'     { $$ = $4; }

opt_all_clause:
  ALL        { $$ = nil }
| /*EMPTY*/  { $$ = nil }

opt_sort_clause:
  sort_clause  { $$ = $1 }
| /*EMPTY*/    { $$ = nil }

sort_clause:
  ORDER BY sortby_list  { $$ = $3 }

sortby_list:
  sortby
  {
    $$ = &OrderClause{Exprs: []OrderExpr{$1}}
  }
| sortby_list ',' sortby
  {
    $1.Exprs = append($1.Exprs, $3)
    $$ = $1
  }


sortby:
a_expr USING qual_all_Op opt_nulls_order
  {
    $$ = OrderExpr{Expr: $1, Using: $3, Nulls: $4}
  }
| a_expr opt_asc_desc opt_nulls_order
  {
    $$ = OrderExpr{Expr: $1, Order: $2, Nulls: $3}
  }

/*
 * This syntax for group_clause tries to follow the spec quite closely.
 * However, the spec allows only column references, not expressions,
 * which introduces an ambiguity between implicit row constructors
 * (a,b) and lists of column references.
 *
 * We handle this by using the a_expr production for what the spec calls
 * <ordinary grouping set>, which in the spec represents either one column
 * reference or a parenthesized list of column references. Then, we check the
 * top node of the a_expr to see if it's an implicit RowExpr, and if so, just
 * grab and use the list, discarding the node. (this is done in parse analysis,
 * not here)
 *
 * (we abuse the row_format field of RowExpr to distinguish implicit and
 * explicit row constructors; it's debatable if anyone sanely wants to use them
 * in a group clause, but if they have a reason to, we make it possible.)
 *
 * Each item in the group_clause list is either an expression tree or a
 * GroupingSet node of some type.
 */
group_clause:
  GROUP_P BY group_by_list  { $$ = &GroupByClause{Exprs: $3} }
| /*EMPTY*/               { $$ = nil }

group_by_list:
  group_by_item
  {
    $$ = []Expr{$1}
  }
| group_by_list ',' group_by_item
  {
    $$ = append($1, $3)
  }

group_by_item:
  a_expr
/* TODO      | empty_grouping_set          { $$ = $1; }
      | cube_clause             { $$ = $1; }
      | rollup_clause             { $$ = $1; }
      | grouping_sets_clause          { $$ = $1; }
*/

having_clause:
  HAVING a_expr  { $$ = $2 }
| /*EMPTY*/      { $$ = nil }

for_locking_clause:
  for_locking_items   { $$ = $1 }
| FOR READ ONLY       { $$ = nil }

opt_for_locking_clause:
  for_locking_clause  { $$ = $1 }
| /* EMPTY */         { $$ = nil }

for_locking_items:
  for_locking_item
  {
    $$ = &LockingClause{Locks: []LockingItem{$1}}
  }
| for_locking_items for_locking_item
  {
    $1.Locks = append($1.Locks, $2)
    $$ = $1
  }

for_locking_item:
  for_locking_strength locked_rels_list opt_nowait_or_skip
  {
    $$ = LockingItem{Strength: $1, LockedRels: $2, WaitPolicy: $3}
  }

for_locking_strength:
FOR UPDATE            { $$ = "update" }
| FOR NO KEY UPDATE   { $$ = "no key update" }
| FOR SHARE           { $$ = "share" }
| FOR KEY SHARE       { $$ = "key share" }

locked_rels_list:
  OF qualified_name_list  { $$ = $2 }
| /* EMPTY */             { $$ = nil }


/*
 * Window Definitions
 */
window_clause:
      /* TODO WINDOW window_definition_list     { $$ = $2; }
      |*/ /*EMPTY*/               { $$ = nil }
    ;


values_clause: { panic("TODO") }
relation_expr: { panic("TODO") }



select_limit:
  limit_clause offset_clause
  {
    $$ = &LimitClause{Limit: $1, Offset: $2}
  }
| offset_clause limit_clause
  {
    $$ = &LimitClause{Limit: $2, Offset: $1}
  }
| limit_clause
  {
    $$ = &LimitClause{Limit: $1}
  }
| offset_clause
  {
    $$ = &LimitClause{Offset: $1}
  }


opt_select_limit:
  select_limit
| /* EMPTY */   { $$ = nil }

limit_clause:
  LIMIT select_limit_value
  {
    $$ = $2
  }
  /* TODO SQL:2008 syntax */

offset_clause:
  OFFSET select_offset_value
  {
    $$ = $2
  }
  /* TODO SQL:2008 syntax */

select_limit_value:
  a_expr      { $$ = $1; }
| ALL
  {
    $$ = nil
  }

select_offset_value:
  a_expr   { $$ = $1 }



/*****************************************************************************
 *
 *  clauses common to all Optimizable Stmts:
 *    from_clause   - allow list of both JOIN expressions and table names
 *    where_clause  - qualifications for joins or restrictions
 *
 *****************************************************************************/




where_clause:
  WHERE a_expr   { $$ = &WhereClause{Expr: $2} }
| /*EMPTY*/      { $$ = nil }



all_Op:
  Op { $$ = string($1) }
| MathOp { $$ = string($1) }

MathOp:
  '+'             { $$ = "+" }
| '-'             { $$ = "-" }
| '*'             { $$ = "*" }
| '/'             { $$ = "/" }
| '%'             { $$ = "%" }
| '^'             { $$ = "^" }
| '<'             { $$ = "<" }
| '>'             { $$ = ">" }
| '='             { $$ = "=" }
| LESS_EQUALS     { $$ = "<=" }
| GREATER_EQUALS  { $$ = ">=" }
| NOT_EQUALS      { $$ = "<>" }

qual_Op:
  Op { $$ = string($1) }
| OPERATOR '(' any_operator ')' { $$ = $3 }

qual_all_Op:
  all_Op { $$ = string($1) }
| OPERATOR '(' any_operator ')' { $$ = $3 }


columnref:
ColId
  {
    $$ = ColumnRef{Column: $1}
  }
| ColId indirection
  {
    $$ = ColumnRef{Table: $1, Column: $2[0]}
  }



indirection_el:
  '.' attr_name
  {
    $$ = $2
  }
| '.' '*'
  {
    $$ = "*"
  }
/* TODO      | '[' a_expr ']'
        {
          A_Indices *ai = makeNode(A_Indices);
          ai->lidx = NULL;
          ai->uidx = $2;
          $$ = (Node *) ai;
        }
      | '[' a_expr ':' a_expr ']'
        {
          A_Indices *ai = makeNode(A_Indices);
          ai->lidx = $2;
          ai->uidx = $4;
          $$ = (Node *) ai;
        }*/

indirection:
  indirection_el              { $$ = []string{$1} }
| indirection indirection_el  { $$ = append($1, $2) }



/*****************************************************************************
 *
 *  target list for SELECT
 *
 *****************************************************************************/

opt_target_list:
  target_list  { $$ = $1 }
| /* EMPTY */  { $$ = nil }

target_list:
  target_el    { $$ = []Expr{$1} }
| target_list ',' target_el
  {
    $$ = append($1, $3)
  }

target_el:
  a_expr AS ColLabel
  {
    $$ = AliasedExpr{Expr: $1, Alias: $3}
  }
| a_expr IDENT
  {
    $$ = AliasedExpr{Expr: $1, Alias: $2}
  }
| a_expr
| '*'
  {
    $$ = ColumnRef{Column: "*"}
  }



/*****************************************************************************
 *
 *  Names and constants
 *
 *****************************************************************************/

qualified_name_list:
  qualified_name
  {
    $$ = []string{$1}
  }
| qualified_name_list ',' qualified_name
  {
    $$ = append($1, $3)
  }

/*
 * The production for a qualified relation name has to exactly match the
 * production for a qualified func_name, because in a FROM clause we cannot
 * tell which we are parsing until we see what comes after it ('(' for a
 * func_name, something else for a relation). Therefore we allow 'indirection'
 * which may contain subscripts, and reject that case in the C code.
 */
qualified_name:
  ColId
    {
      $$ = $1
    }
/* TODO
| ColId indirection
  {
    check_qualified_name($2, yyscanner);
    $$ = makeRangeVar(NULL, NULL, @1);
    switch (list_length($2))
    {
      case 1:
        $$->catalogname = NULL;
        $$->schemaname = $1;
        $$->relname = strVal(linitial($2));
        break;
      case 2:
        $$->catalogname = $1;
        $$->schemaname = strVal(linitial($2));
        $$->relname = strVal(lsecond($2));
        break;
      default:
        ereport(ERROR,
            (errcode(ERRCODE_SYNTAX_ERROR),
             errmsg("improper qualified name (too many dotted names): %s",
                NameListToString(lcons(makeString($1), $2))),
             parser_errposition(@1)));
        break;
    }
  }
*/

name_list:
  name { $$ = []string{$1} }
| name_list ',' name
  {
    $$ = append($1, $3)
  }

name:
  ColId { $$ = $1 }

attr_name:
  ColLabel { $$ = $1 }


Iconst:   ICONST
Sconst:   SCONST

SignedIconst:
  Iconst      { $$ = $1 }
/* TODO - determine what to do with numbers
| '+' Iconst  { $$ = + $2 }
| '-' Iconst  { $$ = - $2 }
*/

/*
 * Name classification hierarchy.
 *
 * IDENT is the lexeme returned by the lexer for identifiers that match
 * no known keyword.  In most cases, we can accept certain keywords as
 * names, not only IDENTs.  We prefer to accept as many such keywords
 * as possible to minimize the impact of "reserved words" on programmers.
 * So, we divide names into several possible classes.  The classification
 * is chosen in part to make keywords acceptable as names wherever possible.
 */

/* Column identifier --- names that can be column, table, etc names.
 */
ColId:
  IDENT
| unreserved_keyword
| col_name_keyword

/* Type/function identifier --- names that can be type or function names.
 */
type_function_name:
  IDENT
| unreserved_keyword
| type_func_name_keyword

/* Any not-fully-reserved word --- these names can be, eg, role names.
 */
NonReservedWord:
  IDENT
| unreserved_keyword
| col_name_keyword
| type_func_name_keyword

/* Column label --- allowed labels in "AS" clauses.
 * This presently includes *all* Postgres keywords.
 */
ColLabel:
  IDENT                   { $$ = $1 }
| unreserved_keyword      { $$ = $1 }
| col_name_keyword        { $$ = $1 }
| type_func_name_keyword  { $$ = $1 }
| reserved_keyword        { $$ = $1 }

/*
 * Keyword category lists.  Generally, every keyword present in
 * the Postgres grammar should appear in exactly one of these lists.
 */

/* "Unreserved" keywords --- available for use as any kind of name.
 */
unreserved_keyword:
  ABORT_P
| ABSOLUTE_P
| ACCESS
| ACTION
| ADD_P
| ADMIN
| AFTER
| AGGREGATE
| ALSO
| ALTER
| ALWAYS
| ASSERTION
| ASSIGNMENT
| AT
| ATTRIBUTE
| BACKWARD
| BEFORE
| BEGIN_P
| BY
| CACHE
| CALLED
| CASCADE
| CASCADED
| CATALOG_P
| CHAIN
| CHARACTERISTICS
| CHECKPOINT
| CLASS
| CLOSE
| CLUSTER
| COMMENT
| COMMENTS
| COMMIT
| COMMITTED
| CONFIGURATION
| CONFLICT
| CONNECTION
| CONSTRAINTS
| CONTENT_P
| CONTINUE_P
| CONVERSION_P
| COPY
| COST
| CSV
| CUBE
| CURRENT_P
| CURSOR
| CYCLE
| DATA_P
| DATABASE
| DAY_P
| DEALLOCATE
| DECLARE
| DEFAULTS
| DEFERRED
| DEFINER
| DELETE_P
| DELIMITER
| DELIMITERS
| DICTIONARY
| DISABLE_P
| DISCARD
| DOCUMENT_P
| DOMAIN_P
| DOUBLE_P
| DROP
| EACH
| ENABLE_P
| ENCODING
| ENCRYPTED
| ENUM_P
| ESCAPE
| EVENT
| EXCLUDE
| EXCLUDING
| EXCLUSIVE
| EXECUTE
| EXPLAIN
| EXTENSION
| EXTERNAL
| FAMILY
| FILTER
| FIRST_P
| FOLLOWING
| FORCE
| FORWARD
| FUNCTION
| FUNCTIONS
| GLOBAL
| GRANTED
| HANDLER
| HEADER_P
| HOLD
| HOUR_P
| IDENTITY_P
| IF_P
| IMMEDIATE
| IMMUTABLE
| IMPLICIT_P
| IMPORT_P
| INCLUDING
| INCREMENT
| INDEX
| INDEXES
| INHERIT
| INHERITS
| INLINE_P
| INPUT_P
| INSENSITIVE
| INSERT
| INSTEAD
| INVOKER
| ISOLATION
| KEY
| LABEL
| LANGUAGE
| LARGE_P
| LAST_P
| LEAKPROOF
| LEVEL
| LISTEN
| LOAD
| LOCAL
| LOCATION
| LOCK_P
| LOCKED
| LOGGED
| MAPPING
| MATCH
| MATERIALIZED
| MAXVALUE
| MINUTE_P
| MINVALUE
| MODE
| MONTH_P
| MOVE
| NAME_P
| NAMES
| NEXT
| NO
| NOTHING
| NOTIFY
| NOWAIT
| NULLS_P
| OBJECT_P
| OF
| OFF
| OIDS
| OPERATOR
| OPTION
| OPTIONS
| ORDINALITY
| OVER
| OWNED
| OWNER
| PARSER
| PARTIAL
| PARTITION
| PASSING
| PASSWORD
| PLANS
| POLICY
| PRECEDING
| PREPARE
| PREPARED
| PRESERVE
| PRIOR
| PRIVILEGES
| PROCEDURAL
| PROCEDURE
| PROGRAM
| QUOTE
| RANGE
| READ
| REASSIGN
| RECHECK
| RECURSIVE
| REF
| REFRESH
| REINDEX
| RELATIVE_P
| RELEASE
| RENAME
| REPEATABLE
| REPLACE
| REPLICA
| RESET
| RESTART
| RESTRICT
| RETURNS
| REVOKE
| ROLE
| ROLLBACK
| ROLLUP
| ROWS
| RULE
| SAVEPOINT
| SCHEMA
| SCROLL
| SEARCH
| SECOND_P
| SECURITY
| SEQUENCE
| SEQUENCES
| SERIALIZABLE
| SERVER
| SESSION
| SET
| SETS
| SHARE
| SHOW
| SIMPLE
| SKIP
| SNAPSHOT
| SQL_P
| STABLE
| STANDALONE_P
| START
| STATEMENT
| STATISTICS
| STDIN
| STDOUT
| STORAGE
| STRICT_P
| STRIP_P
| SYSID
| SYSTEM_P
| TABLES
| TABLESPACE
| TEMP
| TEMPLATE
| TEMPORARY
| TEXT_P
| TRANSACTION
| TRANSFORM
| TRIGGER
| TRUNCATE
| TRUSTED
| TYPE_P
| TYPES_P
| UNBOUNDED
| UNCOMMITTED
| UNENCRYPTED
| UNKNOWN
| UNLISTEN
| UNLOGGED
| UNTIL
| UPDATE
| VACUUM
| VALID
| VALIDATE
| VALIDATOR
| VALUE_P
| VARYING
| VERSION_P
| VIEW
| VIEWS
| VOLATILE
| WHITESPACE_P
| WITHIN
| WITHOUT
| WORK
| WRAPPER
| WRITE
| XML_P
| YEAR_P
| YES_P
| ZONE


/* Column identifier --- keywords that can be column, table, etc names.
 *
 * Many of these keywords will in fact be recognized as type or function
 * names too; but they have special productions for the purpose, and so
 * can't be treated as "generic" type or function names.
 *
 * The type names appearing here are not usable as function names
 * because they can be followed by '(' in typename productions, which
 * looks too much like a function call for an LR(1) parser.
 */
col_name_keyword:
  BETWEEN
| BIGINT
| BIT
| BOOLEAN_P
| CHAR_P
| CHARACTER
| COALESCE
| DEC
| DECIMAL_P
| EXISTS
| EXTRACT
| FLOAT_P
| GREATEST
| GROUPING
| INOUT
| INT_P
| INTEGER
| INTERVAL
| LEAST
| NATIONAL
| NCHAR
| NONE
| NULLIF
| NUMERIC
| OUT_P
| OVERLAY
| POSITION
| PRECISION
| REAL
| ROW
| SETOF
| SMALLINT
| SUBSTRING
| TIME
| TIMESTAMP
| TREAT
| TRIM
| VALUES
| VARCHAR
| XMLATTRIBUTES
| XMLCONCAT
| XMLELEMENT
| XMLEXISTS
| XMLFOREST
| XMLPARSE
| XMLPI
| XMLROOT
| XMLSERIALIZE

/* Type/function identifier --- keywords that can be type or function names.
 *
 * Most of these are keywords that are used as operators in expressions;
 * in general such keywords can't be column names because they would be
 * ambiguous with variables, but they are unambiguous as function identifiers.
 *
 * Do not include POSITION, SUBSTRING, etc here since they have explicit
 * productions in a_expr to support the goofy SQL9x argument syntax.
 * - thomas 2000-11-28
 */
type_func_name_keyword:
  AUTHORIZATION
| BINARY
| COLLATION
| CONCURRENTLY
| CROSS
| CURRENT_SCHEMA
| FREEZE
| FULL
| ILIKE
| INNER_P
| IS
| ISNULL
| JOIN
| LEFT
| LIKE
| NATURAL
| NOTNULL
| OUTER_P
| OVERLAPS
| RIGHT
| SIMILAR
| TABLESAMPLE
| VERBOSE

/* Reserved keyword --- these keywords are usable only as a ColLabel.
 *
 * Keywords appear here if they could not be distinguished from variable,
 * type, or function names in some contexts.  Don't put things here unless
 * forced to.
 */
reserved_keyword:
  ALL
| ANALYSE
| ANALYZE
| AND
| ANY
| ARRAY
| AS
| ASC
| ASYMMETRIC
| BOTH
| CASE
| CAST
| CHECK
| COLLATE
| COLUMN
| CONSTRAINT
| CREATE
| CURRENT_CATALOG
| CURRENT_DATE
| CURRENT_ROLE
| CURRENT_TIME
| CURRENT_TIMESTAMP
| CURRENT_USER
| DEFAULT
| DEFERRABLE
| DESC
| DISTINCT
| DO
| ELSE
| END_P
| EXCEPT
| FALSE_P
| FETCH
| FOR
| FOREIGN
| FROM
| GRANT
| GROUP_P
| HAVING
| IN_P
| INITIALLY
| INTERSECT
| INTO
| LATERAL_P
| LEADING
| LIMIT
| LOCALTIME
| LOCALTIMESTAMP
| NOT
| NULL_P
| OFFSET
| ON
| ONLY
| OR
| ORDER
| PLACING
| PRIMARY
| REFERENCES
| RETURNING
| SELECT
| SESSION_USER
| SOME
| SYMMETRIC
| TABLE
| THEN
| TO
| TRAILING
| TRUE_P
| UNION
| UNIQUE
| USER
| USING
| VARIADIC
| WHEN
| WHERE
| WINDOW
| WITH

%%

// The parser expects the lexer to return 0 on EOF.  Give it a name
// for clarity.
const eof = 0

