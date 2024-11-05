# **************************************************** LIBRARY MANAGEMENT *************************************************************************

# ***************************************************** CREATING DATABASE *********************************************************************

Create database library;

# ******************************************************* USING DATABASE ***********************************************************************

Use library;

# ************************************************* CREATING TABLES AND IMPORTING DATA FROM CSV FILES *************************************************************

# ************************************************ PUBLISHERS TABLE ***********************************************************************************************

# This table contains information about Publishers of Books

Create table Publishers(Publisher_name varchar(255) Primary Key,
                        Publisher_address varchar(255),
                        Publisher_phone varchar(255));
                        
Select * from Publishers;

# ************************************************ BOOKS TABLE **************************************************************************************************

# This tables contains information about Books

Create table Books(Book_id tinyint primary key auto_increment,
                   Book_title varchar(255),
                   Book_publisher_name varchar(255),
                   foreign key (Book_publisher_name) references Publishers(Publisher_name) on update cascade on delete cascade
                   );
                   
Select * from Books;

# *************************************************** AUTHORS TABLE *************************************************************************************************

# This table contains information about Authors of different Books.

Create table Authors(Author_id tinyint Primary key auto_increment,
                     Author_book_id tinyint,
                     Author_name varchar(255),
                     foreign key (Author_book_id) references Books(Book_id) on update cascade on delete cascade);
					
Select * from Authors;

# ***************************************** LIBRARY BRANCHES TABLE *******************************************************************************

# This table contains information of Library Branchs.

Create table Library_branch(Branch_id tinyint Primary key auto_increment,
                            Branch_name varchar(255),
                            Branch_address varchar(255));

Select * from Library_branch; 

# *************************************** BORROWERS TABLE ******************************************************************************************

# This table contains information about Borrowers who took Book Loans.

Create table Borrowers(Borrower_cardNo tinyint Primary key auto_increment,
                       Borrower_name varchar(255),
                       Borrower_address varchar(255),
                       Borrower_phone varchar(255))auto_increment = 100;
                       
Select * from Borrowers;

# ****************************************** BOOK COPIES TABLE ****************************************************************************************

# This table contains information about Book Copies of each Book.

Create table Book_copies(Copies_id tinyint Primary Key auto_increment,
						 Copies_bookid tinyint,
                         Copies_branchid tinyint,
                         no_of_copies tinyint,
                         foreign key (Copies_bookid) references Books(Book_id) on update cascade on delete cascade,
                         foreign key (Copies_branchid) references Library_Branch(Branch_id) on update cascade on delete cascade);
                         
Select * from Book_copies;

# ********************************************* BOOK LOANS TABLE *******************************************************************************************

# This table contains information about Book Loans of Borrowers.

Create table Book_loans(LoanId tinyint Primary key auto_increment,
						Loan_bookId tinyint,
                        Loan_BranchId tinyint,
                        Loan_cardNo tinyint,
                        Loan_dateout varchar(255),
                        Loan_Duedate  varchar(255),
                        foreign key (Loan_bookId) references Books(Book_id) on update cascade on delete cascade,
                        foreign key (Loan_BranchId) references Library_Branch(Branch_id) on update cascade on delete cascade,
                        foreign key (Loan_cardNo) references Borrowers(Borrower_cardNo) on update cascade on delete cascade);

Select * from Book_loans;

# ********************************************** DATA CLEANING ***************************************************************************************

# The columns Loan_dateout and Loan_Duedate in Book_Loans are of string datatype but data in it is of "Date" type so to aviod that problem this two 
-- columns are set to  Date datatype using "str_to_date()" built-in data type function.

update book_loans set Loan_dateout = str_to_date(Loan_dateout,"%m/%d/%y") where LoanId > 0;

update book_loans set Loan_Duedate = str_to_date(Loan_Duedate,"%m/%d/%y") where LoanId > 0;


# *************************************************** QUERY SOLVING ****************************************************************************************


# 1.How many copies of the book titled "The Lost Tribe" are owned by the library branch whose name is "Sharpstown"?

Select count(Copies_id) from Book_copies
        Left Join Books
        on Book_copies.Copies_bookid = Books.Book_id
        Inner Join Library_branch
        on Library_branch.Branch_id = Book_copies.Copies_Branchid
        where Book_title = "The Lost Tribe" and Branch_name = "Sharpstown";

# *************************************************************************************************************************************************************

# 2.How many copies of the book titled "The Lost Tribe" are owned by each library branch?

Select Branch_name,Book_title,count(Copies_id) from Book_copies
        Left Join Books
        on Book_copies.Copies_bookid = Books.Book_id
        Inner Join Library_branch
        on Library_branch.Branch_id = Book_copies.Copies_Branchid
        where Book_title = "The Lost Tribe"
        Group by Branch_name,Book_title;

# *****************************************************************************************************************************************************************

# 3.Retrieve the names of all borrowers who do not have any books checked out.

Select borrower_name from Borrowers
        Left Join Book_loans 
        on Borrowers.Borrower_cardNo = Book_loans.Loan_cardNo
		where Loan_dateout is null;

# ****************************************************************************************************************************************************************

# 4.For each book that is loaned out from the "Sharpstown" branch and whose DueDate is 2/3/18, retrieve the book title, the borrower's name, and the borrower's address. 

Select borrower_name,borrower_address,book_title from Borrowers 
          Left Join Book_loans
          on Borrowers.Borrower_cardNo = Book_loans.Loan_cardNo
          Left Join Books
          on Books.Book_id = Book_loans.Loan_Bookid
          Left Join Library_branch 
          on Library_branch.branch_id = Book_loans.Loan_Branchid
          where Branch_name = "Sharpstown" and Loan_duedate = "2018-02-03";
          
# *********************************************************************************************************************************************************************
          
# 5.For each library branch, retrieve the branch name and the total number of books loaned out from that branch.

Select Branch_name,count(Loan_bookid) from Library_Branch
            Left Join Book_loans
            on Library_Branch.Branch_id = Book_loans.Loan_Branchid
            Group by Branch_name;
            
# ************************************************************************************************************************************************************************

# 6.Retrieve the names, addresses, and number of books checked out for all borrowers who have more than five books checked out.

Select borrower_name,borrower_address,count(Loan_bookid) as book_count from Borrowers
           Join Book_loans
           on Borrowers.Borrower_cardNo = Book_loans.Loan_cardNo
           Group by borrower_name,borrower_address 
           Having book_count > 5;
            
# **********************************************************************************************************************************************************************

# 7.For each book authored by "Stephen King", retrieve the title and the number of copies owned by the library branch whose name is "Central".

Select book_title,no_of_copies from Authors
          Left Join Books
          on Author_book_id = Books.Book_id
          Left Join Book_copies
          on Books.Book_id = Book_Copies.Copies_bookid
          Left Join Library_Branch
          on Book_Copies.Copies_branchid = Library_branch.Branch_id
          where Author_name = "Stephen King" and  Branch_name = "Central";
          
 # **********************************************************************************************************************************************************************        
