-- Idea is to have a gallery with different sections
-- A gallery can have multiple sections
-- Author table can have info about there life
-- In different Sections there will be vairous painting with different types, medium etc. 
-- Painting_Styles table is added for normalization
-- Each sections will have assigned manager with there neccesary info
-- Visitor table is also included for the purpose of daily logs i.e linkes to daily activities
-- Transaction table to store buyer_name, type of payment and to ideantify if it was purchased or is it on loan

------------------MASTER TABLES--------------------------

-- Master Tables
CREATE TABLE Gallery (
    Gallery_id SERIAL PRIMARY KEY,
    Gallery_Name VARCHAR(50) UNIQUE
);

CREATE TABLE Sections (
    Section_id SERIAL PRIMARY KEY,
    Section_Name VARCHAR(100),
    Gallery_id INT REFERENCES Gallery(Gallery_id) ON DELETE CASCADE
);

CREATE TABLE Author (
    Author_id SERIAL PRIMARY KEY,
    Name VARCHAR(100),
    Age INT CHECK (Age >= 0),
    place_of_birth VARCHAR(50),
    birthdate DATE,
    biography VARCHAR(1000)
);

CREATE TABLE Medium (
    Medium_id SERIAL PRIMARY KEY,
    Medium_Name VARCHAR(100) UNIQUE
);

CREATE TABLE Styles (
    Style_id SERIAL PRIMARY KEY,
    Style_Name VARCHAR(100) UNIQUE
);

CREATE TABLE Manager (
    Manager_id SERIAL PRIMARY KEY,
    Name_of_Manager VARCHAR(50),
    Age INT CHECK (Age >= 0),
    POB VARCHAR(50),
    Contact TEXT,
    Time_Shift TIME NOT NULL
);
-----
CREATE TABLE Visitor (
    Visitor_id SERIAL PRIMARY KEY,
    Name VARCHAR(100),
    Age INT CHECK (Age >= 0),
    Location VARCHAR(100)
);

CREATE TABLE Payment_Method (
    Method_id SERIAL PRIMARY KEY,
    Method_Name VARCHAR(50) UNIQUE
);

CREATE TABLE Transaction_Type (
    Type_id SERIAL PRIMARY KEY,
    Type_Name VARCHAR(50) UNIQUE
);

-- Relationship Tables
CREATE TABLE Painting (
    Painting_id SERIAL PRIMARY KEY,
    Title VARCHAR(200),
    Author_id INT REFERENCES Author(Author_id) ON DELETE CASCADE,
    Origin VARCHAR(100),
    Price INT CHECK (Price >= 0),
    Section_id INT REFERENCES Sections(Section_id) ON DELETE CASCADE,
    Medium_id INT REFERENCES Medium(Medium_id) ON DELETE CASCADE,
    Date_Added DATE,
);

CREATE TABLE Painting_Style (
    Painting_id INT REFERENCES Painting(Painting_id) ON DELETE CASCADE,
    Style_id INT REFERENCES Styles(Style_id) ON DELETE CASCADE,
    PRIMARY KEY (Painting_id, Style_id)
);

CREATE TABLE Manager_Section_Assignment (
    Assignment_id SERIAL PRIMARY KEY,
    Manager_id INT REFERENCES Manager(Manager_id) ON DELETE CASCADE,
    Section_id INT REFERENCES Sections(Section_id) ON DELETE CASCADE,
    Assigned_From DATE,
    Assigned_To DATE
);
------
CREATE TABLE DAILY_LOGS (
    Log_id SERIAL PRIMARY KEY,
    Visit_Date DATE,
    Time_in TIME,
    Time_out TIME,
    Visitor_id INT REFERENCES Visitor(Visitor_id) ON DELETE CASCADE,
    Manager_Assigned INT REFERENCES Manager(Manager_id) ON DELETE CASCADE,
    Painting_Visited INT REFERENCES Painting(Painting_id) ON DELETE CASCADE
);
------
CREATE TABLE Transactions (
    transaction_id SERIAL PRIMARY KEY,
    painting_id INT REFERENCES Painting(Painting_id) ON DELETE CASCADE,
    buyer_name VARCHAR(100),
    sale_date DATE,
    amount INT CHECK (amount >= 0),
    payment_method_id INT REFERENCES Payment_Method(Method_id) ON DELETE CASCADE,
    transaction_type_id INT REFERENCES Transaction_Type(Type_id) ON DELETE CASCADE
);

ALTER TABLE Painting
ADD COLUMN Status VARCHAR(20) CHECK (Status IN ('Available', 'Sold', 'On Loan')) DEFAULT 'Available';


-- DROP TABLE  Painting, Author, Manager, DAILY_LOGS,Gallery;