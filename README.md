# SQL-Interview-Exercises

 Practicing MYSQL in VSCODE easiest and productive approach

In this we will be doing following tasks -> 

1- Installing MySQL-server in Windows (MySQL Sever 8, MySQL workbench 8)
2- installing MySQL database client for vscode
3- running and Practicing MySQL vscode 

Prerequisites => 
    -mysql server 
    -vscode  

# 1- installing MySQL-server in Windows 

https://cdn.mysql.com//Downloads/MySQLInstaller/mysql-installer-web-community-8.0.26.0.msi
install and setup password 

 # 2 - installing MySQL databse client in vscode  
 
 -https://marketplace.visualstudio.com/items?itemName=cweijan.vscode-mysql-client2

 follow given steps to istall and connect to mysql 

# 3 - create a new mysql connection ( JDBC -connection ) 

# 4  - create a .sql file and running and Practicing MySQL in VScode
 
 ---------------------------------------------------------------------------------------

 # Mysql_practice
sample data and queries to practice 

SQL | DDL, DQL, DML, DCL and TCL Commands

Structured Query Language(SQL) as we all know is the database language by the use of which we can perform certain operations on the existing database and also we can use this language to create a database. SQL uses certain commands like Create, Drop, Insert, etc. to carry out the required tasks. 

These SQL commands are mainly categorized into four categories as: 
 

    DDL – Data Definition Language
    DQl – Data Query Language
    DML – Data Manipulation Language
    DCL – Data Control Language

Though many resources claim there to be another category of SQL clauses TCL – Transaction Control Language. So we will see in detail about TCL as well. 

1.DDL(Data Definition Language) : DDL or Data Definition Language actually consists of the SQL commands that can be used to define the database schema. It simply deals with descriptions of the database schema and is used to create and modify the structure of database objects in the database.

Examples of DDL commands: 

    CREATE – is used to create the database or its objects (like table, index, function, views, store procedure and triggers).
    DROP – is used to delete objects from the database.
    ALTER-is used to alter the structure of the database.
    TRUNCATE–is used to remove all records from a table, including all spaces allocated for the records are removed.
    COMMENT –is used to add comments to the data dictionary.
    RENAME –is used to rename an object existing in the database.

2.DQL (Data Query Language) :

DQL statements are used for performing queries on the data within schema objects. The purpose of the DQL Command is to get some schema relation based on the query passed to it. 

Example of DQL: 

    SELECT – is used to retrieve data from the database.

3.DML(Data Manipulation Language): The SQL commands that deals with the manipulation of data present in the database belong to DML or Data Manipulation Language and this includes most of the SQL statements. 


Examples of DML: 

    INSERT – is used to insert data into a table.
    UPDATE – is used to update existing data within a table.
    DELETE – is used to delete records from a database table.

4.DCL(Data Control Language): DCL includes commands such as GRANT and REVOKE which mainly deal with the rights, permissions and other controls of the database system. 

Examples of DCL commands: 

    GRANT-gives users access privileges to the database.
    REVOKE-withdraw user’s access privileges given by using the GRANT command.

TCL(transaction Control Language): TCL commands deal with the transaction within the database. 

Examples of TCL commands: 

    COMMIT– commits a Transaction.
    ROLLBACK– rollbacks a transaction in case of any error occurs.
    SAVEPOINT–sets a savepoint within a transaction.
    SET TRANSACTION–specify characteristics for the transaction.


