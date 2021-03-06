USE [Cosmos]
GO
ALTER TABLE [dbo].[EventRating] DROP CONSTRAINT [FK__EventRati__Event__6383C8BA]
GO
ALTER TABLE [dbo].[EventDetails] DROP CONSTRAINT [FK__EventDeta__Genre__52593CB8]
GO
ALTER TABLE [dbo].[EventDetails] DROP CONSTRAINT [FK__EventDeta__Event__5BE2A6F2]
GO
ALTER TABLE [dbo].[EventDetails] DROP CONSTRAINT [FK__EventDeta__Event__5165187F]
GO
/****** Object:  Table [dbo].[People]    Script Date: 5/9/2020 1:40:01 PM ******/
DROP TABLE [dbo].[People]
GO
/****** Object:  Table [dbo].[MasterData]    Script Date: 5/9/2020 1:40:01 PM ******/
DROP TABLE [dbo].[MasterData]
GO
/****** Object:  Table [dbo].[EventRating]    Script Date: 5/9/2020 1:40:01 PM ******/
DROP TABLE [dbo].[EventRating]
GO
/****** Object:  Table [dbo].[EventPersonRole]    Script Date: 5/9/2020 1:40:01 PM ******/
DROP TABLE [dbo].[EventPersonRole]
GO
/****** Object:  Table [dbo].[EventDetails]    Script Date: 5/9/2020 1:40:01 PM ******/
DROP TABLE [dbo].[EventDetails]
GO
/****** Object:  Table [dbo].[Event]    Script Date: 5/9/2020 1:40:01 PM ******/
DROP TABLE [dbo].[Event]
GO
/****** Object:  StoredProcedure [dbo].[GetJSON]    Script Date: 5/9/2020 1:40:01 PM ******/
DROP PROCEDURE [dbo].[GetJSON]
GO
USE [master]
GO
/****** Object:  Database [Cosmos]    Script Date: 5/9/2020 1:40:01 PM ******/
DROP DATABASE [Cosmos]
GO
/****** Object:  Database [Cosmos]    Script Date: 5/9/2020 1:40:01 PM ******/
CREATE DATABASE [Cosmos]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'Cosmos', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\Cosmos.mdf' , SIZE = 4096KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'Cosmos_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\Cosmos_log.ldf' , SIZE = 1024KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [Cosmos] SET COMPATIBILITY_LEVEL = 110
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [Cosmos].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [Cosmos] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [Cosmos] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [Cosmos] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [Cosmos] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [Cosmos] SET ARITHABORT OFF 
GO
ALTER DATABASE [Cosmos] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [Cosmos] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [Cosmos] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [Cosmos] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [Cosmos] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [Cosmos] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [Cosmos] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [Cosmos] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [Cosmos] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [Cosmos] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [Cosmos] SET  DISABLE_BROKER 
GO
ALTER DATABASE [Cosmos] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [Cosmos] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [Cosmos] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [Cosmos] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [Cosmos] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [Cosmos] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [Cosmos] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [Cosmos] SET RECOVERY FULL 
GO
ALTER DATABASE [Cosmos] SET  MULTI_USER 
GO
ALTER DATABASE [Cosmos] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [Cosmos] SET DB_CHAINING OFF 
GO
ALTER DATABASE [Cosmos] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [Cosmos] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
EXEC sys.sp_db_vardecimal_storage_format N'Cosmos', N'ON'
GO
USE [Cosmos]
GO
/****** Object:  StoredProcedure [dbo].[GetJSON]    Script Date: 5/9/2020 1:40:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GetJSON] @ObjectName VARCHAR(255), @registries_per_request smallint = null
AS
BEGIN
    IF OBJECT_ID(@ObjectName) IS NULL
        BEGIN
            SELECT Json = '';
            RETURN
        END;

    DECLARE @Top NVARCHAR(20) = CASE WHEN @registries_per_request IS NOT NULL 
                                    THEN 'TOP (' + CAST(@registries_per_request AS NVARCHAR) + ') ' 
                                    ELSE '' 
                                END;

    DECLARE @SQL NVARCHAR(MAX) = N'SELECT ' + @Top + '* INTO ##T ' + 
                                'FROM ' + @ObjectName;

    EXECUTE SP_EXECUTESQL @SQL;

    DECLARE @X NVARCHAR(MAX) = '[' + (SELECT * FROM ##T FOR XML PATH('')) + ']';


    SELECT  @X = REPLACE(@X, '<' + Name + '>', 
                    CASE WHEN ROW_NUMBER() OVER(ORDER BY Column_ID) = 1 THEN '{'
                         ELSE '' END + '''' + Name + ''':'''),
            @X = REPLACE(@X, '</' + Name + '>', ''','),
            @X = REPLACE(@X, ',{', '}, {'),
            @X = REPLACE(@X, ',]', '}]')
    FROM    sys.columns
    WHERE   [Object_ID] = OBJECT_ID(@ObjectName)
    ORDER BY Column_ID;

    DROP TABLE ##T;

    SELECT  Json = @X;

END

GO
/****** Object:  Table [dbo].[Event]    Script Date: 5/9/2020 1:40:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Event](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[Event] [nvarchar](4000) NOT NULL,
	[Date] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[EventDetails]    Script Date: 5/9/2020 1:40:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EventDetails](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[EventId] [bigint] NOT NULL,
	[EventTypeId] [smallint] NOT NULL,
	[GenreTypeId] [smallint] NOT NULL,
	[CreatedOn] [date] NOT NULL CONSTRAINT [DF_EventDetails_CreatedOn]  DEFAULT (getdate()),
	[ModifiedOn] [date] NOT NULL CONSTRAINT [DF_EventDetails_ModifiedOn]  DEFAULT (getdate()),
	[CreatedBy] [nvarchar](255) NOT NULL CONSTRAINT [DF_EventDetails_CreatedBy]  DEFAULT (N'ADMIN'),
	[ModifedBy] [nvarchar](255) NOT NULL CONSTRAINT [DF_EventDetails_ModifedBy]  DEFAULT (N'ADMIN')
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[EventPersonRole]    Script Date: 5/9/2020 1:40:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EventPersonRole](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[EventId] [bigint] NOT NULL,
	[PersonId] [int] NOT NULL,
	[RoleId] [smallint] NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[EventRating]    Script Date: 5/9/2020 1:40:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EventRating](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[EventId] [bigint] NOT NULL,
	[Rating] [nvarchar](255) NOT NULL,
	[Comments] [nvarchar](255) NULL,
	[Story] [nvarchar](255) NULL,
	[WhyToWatch] [nvarchar](255) NULL,
	[CreatedOn] [date] NOT NULL CONSTRAINT [ER_EventDetails_CreatedOn]  DEFAULT (getdate()),
	[ModifiedOn] [date] NOT NULL CONSTRAINT [ER_EventDetails_ModifiedOn]  DEFAULT (getdate()),
	[CreatedBy] [nvarchar](255) NOT NULL CONSTRAINT [ER_EventDetails_CreatedBy]  DEFAULT (N'ADMIN'),
	[ModifedBy] [nvarchar](255) NOT NULL CONSTRAINT [ER_EventDetails_ModifedBy]  DEFAULT (N'ADMIN')
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[MasterData]    Script Date: 5/9/2020 1:40:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MasterData](
	[Id] [smallint] IDENTITY(1,1) NOT NULL,
	[Code] [nvarchar](255) NOT NULL,
	[Code_Value] [nvarchar](255) NOT NULL,
	[Code_Description] [nvarchar](255) NOT NULL,
	[IsHidden] [bit] NOT NULL CONSTRAINT [Default_IsHidden]  DEFAULT ((0)),
	[AddedOn] [date] NOT NULL CONSTRAINT [Default_AddedOn]  DEFAULT (getdate()),
	[ModifiedOn] [date] NOT NULL CONSTRAINT [Default_ModifiedOn]  DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[People]    Script Date: 5/9/2020 1:40:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[People](
	[Id] [int] NOT NULL,
	[Name] [nvarchar](255) NOT NULL,
	[FirstName] [nvarchar](255) NULL,
	[LastName] [nvarchar](255) NULL,
	[DOB] [date] NULL,
	[Place] [nvarchar](255) NULL,
	[District] [smallint] NULL,
	[State] [smallint] NULL,
	[Country] [smallint] NULL,
	[Height] [decimal](4, 2) NULL,
	[Weight] [tinyint] NULL,
	[School] [nvarchar](255) NULL,
	[College] [nvarchar](255) NULL,
	[DOD] [date] NULL
) ON [PRIMARY]

GO
SET IDENTITY_INSERT [dbo].[Event] ON 

GO
INSERT [dbo].[Event] ([Id], [Event], [Date]) VALUES (1, N'Vetri', CAST(N'1984-02-17 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[Event] ([Id], [Event], [Date]) VALUES (2, N'Kudumbam', CAST(N'1984-11-22 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[Event] ([Id], [Event], [Date]) VALUES (3, N'Vasantha Raagam', CAST(N'1986-08-01 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[Event] ([Id], [Event], [Date]) VALUES (4, N'Sattam Oru Vilayaattu', CAST(N'1987-10-21 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[Event] ([Id], [Event], [Date]) VALUES (5, N'Ithu Engal Neethi', CAST(N'1988-02-12 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[Event] ([Id], [Event], [Date]) VALUES (6, N'Naalaiya Theerpu', CAST(N'1992-12-04 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[Event] ([Id], [Event], [Date]) VALUES (7, N' Sendhoorapandi', CAST(N'1993-12-24 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[Event] ([Id], [Event], [Date]) VALUES (8, N'Rasigan', CAST(N'1994-07-08 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[Event] ([Id], [Event], [Date]) VALUES (9, N'Deva ', CAST(N'1995-02-17 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[Event] ([Id], [Event], [Date]) VALUES (10, N'Rajavin Parvaiyile', CAST(N'1995-08-05 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[Event] ([Id], [Event], [Date]) VALUES (11, N'Vishnu ', CAST(N'1995-08-17 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[Event] ([Id], [Event], [Date]) VALUES (12, N'Chandralekha', CAST(N'1995-10-23 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[Event] ([Id], [Event], [Date]) VALUES (13, N'Coimbatore Mappillai', CAST(N'1996-01-15 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[Event] ([Id], [Event], [Date]) VALUES (14, N'Poove Unakkaga', CAST(N'1996-02-15 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[Event] ([Id], [Event], [Date]) VALUES (15, N'Vasantha Vaasal', CAST(N'1996-03-22 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[Event] ([Id], [Event], [Date]) VALUES (16, N'Maanbumigu Maanavan', CAST(N'1996-04-12 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[Event] ([Id], [Event], [Date]) VALUES (17, N'Selva', CAST(N'1996-12-12 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[Event] ([Id], [Event], [Date]) VALUES (18, N'Kaalamellam Kaathiruppen', CAST(N'1997-01-14 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[Event] ([Id], [Event], [Date]) VALUES (19, N'Love Today', CAST(N'1997-05-09 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[Event] ([Id], [Event], [Date]) VALUES (20, N'Once More', CAST(N'1997-07-04 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[Event] ([Id], [Event], [Date]) VALUES (21, N'Nerrukku Ner', CAST(N'1997-09-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[Event] ([Id], [Event], [Date]) VALUES (22, N'Kadhalukku Mariyadhai', CAST(N'1997-12-19 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[Event] ([Id], [Event], [Date]) VALUES (23, N'Ninaithen Vandhai', CAST(N'1998-04-10 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[Event] ([Id], [Event], [Date]) VALUES (24, N'Priyamudan', CAST(N'1998-06-12 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[Event] ([Id], [Event], [Date]) VALUES (25, N'Nilaave Vaa', CAST(N'1998-08-14 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[Event] ([Id], [Event], [Date]) VALUES (26, N'Thulladha Manamum Thullum', CAST(N'1999-01-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[Event] ([Id], [Event], [Date]) VALUES (27, N'Endrendrum Kadhal', CAST(N'1999-03-05 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[Event] ([Id], [Event], [Date]) VALUES (28, N'Nenjinile', CAST(N'1999-06-25 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[Event] ([Id], [Event], [Date]) VALUES (29, N'Minsara Kanna', CAST(N'1999-09-09 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[Event] ([Id], [Event], [Date]) VALUES (30, N'Kannukkul Nilavu', CAST(N'2000-01-14 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[Event] ([Id], [Event], [Date]) VALUES (31, N'Kushi', CAST(N'2000-05-19 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[Event] ([Id], [Event], [Date]) VALUES (32, N'Priyamaanavale', CAST(N'2000-10-26 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[Event] ([Id], [Event], [Date]) VALUES (33, N'Friends', CAST(N'2001-01-14 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[Event] ([Id], [Event], [Date]) VALUES (34, N'Badri ', CAST(N'2001-04-12 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[Event] ([Id], [Event], [Date]) VALUES (35, N'Shahjahan', CAST(N'2001-11-14 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[Event] ([Id], [Event], [Date]) VALUES (36, N'Thamizhan', CAST(N'2002-04-12 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[Event] ([Id], [Event], [Date]) VALUES (37, N'Youth', CAST(N'2002-07-19 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[Event] ([Id], [Event], [Date]) VALUES (38, N'Bagavathi', CAST(N'2002-11-04 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[Event] ([Id], [Event], [Date]) VALUES (39, N'Vaseegara ', CAST(N'2003-01-15 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[Event] ([Id], [Event], [Date]) VALUES (40, N'Pudhiya Geethai', CAST(N'2003-05-08 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[Event] ([Id], [Event], [Date]) VALUES (41, N'Thirumalai', CAST(N'2003-10-24 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[Event] ([Id], [Event], [Date]) VALUES (42, N'Udhaya', CAST(N'2004-03-30 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[Event] ([Id], [Event], [Date]) VALUES (43, N'Ghilli', CAST(N'2004-04-17 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[Event] ([Id], [Event], [Date]) VALUES (44, N'Madhurey', CAST(N'2004-08-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[Event] ([Id], [Event], [Date]) VALUES (45, N'Thirupaachi', CAST(N'2005-01-14 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[Event] ([Id], [Event], [Date]) VALUES (46, N'Sukran', CAST(N'2005-02-18 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[Event] ([Id], [Event], [Date]) VALUES (47, N'Sachein', CAST(N'2005-04-14 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[Event] ([Id], [Event], [Date]) VALUES (48, N'Sivakasi ', CAST(N'2005-11-01 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[Event] ([Id], [Event], [Date]) VALUES (49, N'Aathi', CAST(N'2006-01-14 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[Event] ([Id], [Event], [Date]) VALUES (50, N'Pokkiri', CAST(N'2007-01-12 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[Event] ([Id], [Event], [Date]) VALUES (51, N'Azhagiya Tamil Magan', CAST(N'2007-11-08 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[Event] ([Id], [Event], [Date]) VALUES (52, N'Kuruvi', CAST(N'2008-05-03 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[Event] ([Id], [Event], [Date]) VALUES (53, N'Pandhayam', CAST(N'2008-09-19 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[Event] ([Id], [Event], [Date]) VALUES (54, N'Villu', CAST(N'2009-01-12 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[Event] ([Id], [Event], [Date]) VALUES (55, N'Vettaikaaran', CAST(N'2009-12-18 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[Event] ([Id], [Event], [Date]) VALUES (56, N'Sura', CAST(N'2010-04-30 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[Event] ([Id], [Event], [Date]) VALUES (57, N'Kaavalan', CAST(N'2011-01-15 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[Event] ([Id], [Event], [Date]) VALUES (58, N'Velayudham', CAST(N'2011-10-26 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[Event] ([Id], [Event], [Date]) VALUES (59, N'Nanban ', CAST(N'2012-01-12 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[Event] ([Id], [Event], [Date]) VALUES (60, N'Rowdy Rathore', CAST(N'2012-06-01 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[Event] ([Id], [Event], [Date]) VALUES (61, N'Thuppakki', CAST(N'2012-11-13 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[Event] ([Id], [Event], [Date]) VALUES (62, N'Thalaivaa', CAST(N'2013-08-09 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[Event] ([Id], [Event], [Date]) VALUES (63, N'Jilla', CAST(N'2014-01-09 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[Event] ([Id], [Event], [Date]) VALUES (64, N'Kaththi', CAST(N'2014-10-22 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[Event] ([Id], [Event], [Date]) VALUES (65, N'Puli ', CAST(N'2015-10-01 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[Event] ([Id], [Event], [Date]) VALUES (66, N'Theri', CAST(N'2016-04-14 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[Event] ([Id], [Event], [Date]) VALUES (67, N'Bairavaa', CAST(N'2017-01-12 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[Event] ([Id], [Event], [Date]) VALUES (68, N'Mersal', CAST(N'2017-10-18 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[Event] ([Id], [Event], [Date]) VALUES (69, N'Sarkar', CAST(N'2018-11-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[Event] ([Id], [Event], [Date]) VALUES (70, N'Bigil', CAST(N'2019-10-25 00:00:00.000' AS DateTime))
GO
SET IDENTITY_INSERT [dbo].[Event] OFF
GO
SET IDENTITY_INSERT [dbo].[EventDetails] ON 

GO
INSERT [dbo].[EventDetails] ([Id], [EventId], [EventTypeId], [GenreTypeId], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (1, 1, 1685, 1686, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventDetails] ([Id], [EventId], [EventTypeId], [GenreTypeId], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (3, 2, 1685, 1687, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventDetails] ([Id], [EventId], [EventTypeId], [GenreTypeId], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (4, 3, 1685, 1687, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventDetails] ([Id], [EventId], [EventTypeId], [GenreTypeId], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (5, 4, 1685, 1687, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventDetails] ([Id], [EventId], [EventTypeId], [GenreTypeId], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (6, 5, 1685, 1687, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventDetails] ([Id], [EventId], [EventTypeId], [GenreTypeId], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (7, 6, 1685, 1687, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventDetails] ([Id], [EventId], [EventTypeId], [GenreTypeId], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (8, 7, 1685, 1687, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventDetails] ([Id], [EventId], [EventTypeId], [GenreTypeId], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (9, 8, 1685, 1687, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventDetails] ([Id], [EventId], [EventTypeId], [GenreTypeId], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (10, 9, 1685, 1687, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventDetails] ([Id], [EventId], [EventTypeId], [GenreTypeId], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (11, 10, 1685, 1687, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventDetails] ([Id], [EventId], [EventTypeId], [GenreTypeId], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (12, 11, 1685, 1687, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventDetails] ([Id], [EventId], [EventTypeId], [GenreTypeId], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (13, 12, 1685, 1687, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventDetails] ([Id], [EventId], [EventTypeId], [GenreTypeId], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (14, 13, 1685, 1687, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventDetails] ([Id], [EventId], [EventTypeId], [GenreTypeId], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (15, 14, 1685, 1687, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventDetails] ([Id], [EventId], [EventTypeId], [GenreTypeId], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (16, 15, 1685, 1687, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventDetails] ([Id], [EventId], [EventTypeId], [GenreTypeId], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (17, 16, 1685, 1687, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventDetails] ([Id], [EventId], [EventTypeId], [GenreTypeId], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (18, 17, 1685, 1687, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventDetails] ([Id], [EventId], [EventTypeId], [GenreTypeId], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (19, 18, 1685, 1687, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventDetails] ([Id], [EventId], [EventTypeId], [GenreTypeId], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (20, 19, 1685, 1687, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventDetails] ([Id], [EventId], [EventTypeId], [GenreTypeId], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (21, 20, 1685, 1687, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventDetails] ([Id], [EventId], [EventTypeId], [GenreTypeId], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (22, 21, 1685, 1687, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventDetails] ([Id], [EventId], [EventTypeId], [GenreTypeId], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (23, 22, 1685, 1687, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventDetails] ([Id], [EventId], [EventTypeId], [GenreTypeId], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (24, 23, 1685, 1687, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventDetails] ([Id], [EventId], [EventTypeId], [GenreTypeId], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (25, 24, 1685, 1687, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventDetails] ([Id], [EventId], [EventTypeId], [GenreTypeId], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (26, 25, 1685, 1687, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventDetails] ([Id], [EventId], [EventTypeId], [GenreTypeId], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (27, 26, 1685, 1687, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventDetails] ([Id], [EventId], [EventTypeId], [GenreTypeId], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (28, 27, 1685, 1687, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventDetails] ([Id], [EventId], [EventTypeId], [GenreTypeId], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (29, 28, 1685, 1687, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventDetails] ([Id], [EventId], [EventTypeId], [GenreTypeId], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (30, 29, 1685, 1687, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventDetails] ([Id], [EventId], [EventTypeId], [GenreTypeId], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (31, 30, 1685, 1687, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventDetails] ([Id], [EventId], [EventTypeId], [GenreTypeId], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (32, 31, 1685, 1687, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventDetails] ([Id], [EventId], [EventTypeId], [GenreTypeId], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (33, 32, 1685, 1687, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventDetails] ([Id], [EventId], [EventTypeId], [GenreTypeId], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (34, 33, 1685, 1687, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventDetails] ([Id], [EventId], [EventTypeId], [GenreTypeId], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (35, 34, 1685, 1687, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventDetails] ([Id], [EventId], [EventTypeId], [GenreTypeId], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (36, 35, 1685, 1687, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventDetails] ([Id], [EventId], [EventTypeId], [GenreTypeId], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (37, 36, 1685, 1687, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventDetails] ([Id], [EventId], [EventTypeId], [GenreTypeId], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (38, 37, 1685, 1687, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventDetails] ([Id], [EventId], [EventTypeId], [GenreTypeId], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (39, 38, 1685, 1687, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventDetails] ([Id], [EventId], [EventTypeId], [GenreTypeId], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (40, 39, 1685, 1687, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventDetails] ([Id], [EventId], [EventTypeId], [GenreTypeId], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (41, 40, 1685, 1687, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventDetails] ([Id], [EventId], [EventTypeId], [GenreTypeId], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (42, 41, 1685, 1687, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventDetails] ([Id], [EventId], [EventTypeId], [GenreTypeId], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (43, 42, 1685, 1687, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventDetails] ([Id], [EventId], [EventTypeId], [GenreTypeId], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (44, 43, 1685, 1687, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventDetails] ([Id], [EventId], [EventTypeId], [GenreTypeId], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (45, 44, 1685, 1687, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventDetails] ([Id], [EventId], [EventTypeId], [GenreTypeId], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (46, 45, 1685, 1687, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventDetails] ([Id], [EventId], [EventTypeId], [GenreTypeId], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (47, 46, 1685, 1687, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventDetails] ([Id], [EventId], [EventTypeId], [GenreTypeId], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (48, 47, 1685, 1687, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventDetails] ([Id], [EventId], [EventTypeId], [GenreTypeId], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (49, 48, 1685, 1687, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventDetails] ([Id], [EventId], [EventTypeId], [GenreTypeId], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (50, 49, 1685, 1687, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventDetails] ([Id], [EventId], [EventTypeId], [GenreTypeId], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (51, 50, 1685, 1687, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventDetails] ([Id], [EventId], [EventTypeId], [GenreTypeId], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (52, 51, 1685, 1687, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventDetails] ([Id], [EventId], [EventTypeId], [GenreTypeId], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (53, 52, 1685, 1687, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventDetails] ([Id], [EventId], [EventTypeId], [GenreTypeId], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (54, 53, 1685, 1687, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventDetails] ([Id], [EventId], [EventTypeId], [GenreTypeId], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (55, 54, 1685, 1687, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventDetails] ([Id], [EventId], [EventTypeId], [GenreTypeId], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (56, 55, 1685, 1687, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventDetails] ([Id], [EventId], [EventTypeId], [GenreTypeId], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (57, 56, 1685, 1687, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventDetails] ([Id], [EventId], [EventTypeId], [GenreTypeId], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (58, 57, 1685, 1687, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventDetails] ([Id], [EventId], [EventTypeId], [GenreTypeId], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (59, 58, 1685, 1687, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventDetails] ([Id], [EventId], [EventTypeId], [GenreTypeId], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (60, 59, 1685, 1687, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventDetails] ([Id], [EventId], [EventTypeId], [GenreTypeId], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (61, 60, 1685, 1687, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventDetails] ([Id], [EventId], [EventTypeId], [GenreTypeId], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (62, 61, 1685, 1687, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventDetails] ([Id], [EventId], [EventTypeId], [GenreTypeId], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (63, 62, 1685, 1687, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventDetails] ([Id], [EventId], [EventTypeId], [GenreTypeId], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (64, 63, 1685, 1687, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventDetails] ([Id], [EventId], [EventTypeId], [GenreTypeId], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (65, 64, 1685, 1687, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventDetails] ([Id], [EventId], [EventTypeId], [GenreTypeId], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (66, 65, 1685, 1687, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventDetails] ([Id], [EventId], [EventTypeId], [GenreTypeId], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (67, 66, 1685, 1687, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventDetails] ([Id], [EventId], [EventTypeId], [GenreTypeId], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (68, 67, 1685, 1687, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventDetails] ([Id], [EventId], [EventTypeId], [GenreTypeId], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (69, 68, 1685, 1687, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventDetails] ([Id], [EventId], [EventTypeId], [GenreTypeId], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (70, 69, 1685, 1687, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventDetails] ([Id], [EventId], [EventTypeId], [GenreTypeId], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (71, 70, 1685, 1687, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
SET IDENTITY_INSERT [dbo].[EventDetails] OFF
GO
SET IDENTITY_INSERT [dbo].[EventPersonRole] ON 

GO
INSERT [dbo].[EventPersonRole] ([Id], [EventId], [PersonId], [RoleId]) VALUES (1, 1, 13, 1698)
GO
INSERT [dbo].[EventPersonRole] ([Id], [EventId], [PersonId], [RoleId]) VALUES (2, 1, 15, 1707)
GO
INSERT [dbo].[EventPersonRole] ([Id], [EventId], [PersonId], [RoleId]) VALUES (3, 1, 14, 1706)
GO
SET IDENTITY_INSERT [dbo].[EventPersonRole] OFF
GO
SET IDENTITY_INSERT [dbo].[EventRating] ON 

GO
INSERT [dbo].[EventRating] ([Id], [EventId], [Rating], [Comments], [Story], [WhyToWatch], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (1, 1, N'85%', N'One Time Watch', N'Good script', N'ScreenPlay', CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventRating] ([Id], [EventId], [Rating], [Comments], [Story], [WhyToWatch], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (2, 2, N'85%', N'One Time Watch', N'Good script', N'ScreenPlay', CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventRating] ([Id], [EventId], [Rating], [Comments], [Story], [WhyToWatch], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (3, 3, N'85%', N'One Time Watch', N'Good script', N'ScreenPlay', CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventRating] ([Id], [EventId], [Rating], [Comments], [Story], [WhyToWatch], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (4, 4, N'85%', N'One Time Watch', N'Good script', N'ScreenPlay', CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventRating] ([Id], [EventId], [Rating], [Comments], [Story], [WhyToWatch], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (5, 5, N'85%', N'One Time Watch', N'Good script', N'ScreenPlay', CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventRating] ([Id], [EventId], [Rating], [Comments], [Story], [WhyToWatch], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (6, 6, N'85%', N'One Time Watch', N'Good script', N'ScreenPlay', CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventRating] ([Id], [EventId], [Rating], [Comments], [Story], [WhyToWatch], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (7, 7, N'85%', N'One Time Watch', N'Good script', N'ScreenPlay', CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventRating] ([Id], [EventId], [Rating], [Comments], [Story], [WhyToWatch], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (8, 8, N'85%', N'One Time Watch', N'Good script', N'ScreenPlay', CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventRating] ([Id], [EventId], [Rating], [Comments], [Story], [WhyToWatch], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (9, 9, N'85%', N'One Time Watch', N'Good script', N'ScreenPlay', CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventRating] ([Id], [EventId], [Rating], [Comments], [Story], [WhyToWatch], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (10, 10, N'85%', N'One Time Watch', N'Good script', N'ScreenPlay', CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventRating] ([Id], [EventId], [Rating], [Comments], [Story], [WhyToWatch], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (11, 11, N'85%', N'One Time Watch', N'Good script', N'ScreenPlay', CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventRating] ([Id], [EventId], [Rating], [Comments], [Story], [WhyToWatch], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (12, 12, N'85%', N'One Time Watch', N'Good script', N'ScreenPlay', CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventRating] ([Id], [EventId], [Rating], [Comments], [Story], [WhyToWatch], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (13, 13, N'85%', N'One Time Watch', N'Good script', N'ScreenPlay', CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventRating] ([Id], [EventId], [Rating], [Comments], [Story], [WhyToWatch], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (14, 14, N'85%', N'One Time Watch', N'Good script', N'ScreenPlay', CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventRating] ([Id], [EventId], [Rating], [Comments], [Story], [WhyToWatch], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (15, 15, N'85%', N'One Time Watch', N'Good script', N'ScreenPlay', CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventRating] ([Id], [EventId], [Rating], [Comments], [Story], [WhyToWatch], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (16, 16, N'85%', N'One Time Watch', N'Good script', N'ScreenPlay', CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventRating] ([Id], [EventId], [Rating], [Comments], [Story], [WhyToWatch], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (17, 17, N'85%', N'One Time Watch', N'Good script', N'ScreenPlay', CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventRating] ([Id], [EventId], [Rating], [Comments], [Story], [WhyToWatch], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (18, 18, N'85%', N'One Time Watch', N'Good script', N'ScreenPlay', CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventRating] ([Id], [EventId], [Rating], [Comments], [Story], [WhyToWatch], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (19, 19, N'85%', N'One Time Watch', N'Good script', N'ScreenPlay', CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventRating] ([Id], [EventId], [Rating], [Comments], [Story], [WhyToWatch], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (20, 20, N'85%', N'One Time Watch', N'Good script', N'ScreenPlay', CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventRating] ([Id], [EventId], [Rating], [Comments], [Story], [WhyToWatch], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (21, 21, N'85%', N'One Time Watch', N'Good script', N'ScreenPlay', CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventRating] ([Id], [EventId], [Rating], [Comments], [Story], [WhyToWatch], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (22, 22, N'85%', N'One Time Watch', N'Good script', N'ScreenPlay', CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventRating] ([Id], [EventId], [Rating], [Comments], [Story], [WhyToWatch], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (23, 23, N'85%', N'One Time Watch', N'Good script', N'ScreenPlay', CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventRating] ([Id], [EventId], [Rating], [Comments], [Story], [WhyToWatch], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (24, 24, N'85%', N'One Time Watch', N'Good script', N'ScreenPlay', CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventRating] ([Id], [EventId], [Rating], [Comments], [Story], [WhyToWatch], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (25, 25, N'85%', N'One Time Watch', N'Good script', N'ScreenPlay', CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventRating] ([Id], [EventId], [Rating], [Comments], [Story], [WhyToWatch], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (26, 26, N'85%', N'One Time Watch', N'Good script', N'ScreenPlay', CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventRating] ([Id], [EventId], [Rating], [Comments], [Story], [WhyToWatch], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (27, 27, N'85%', N'One Time Watch', N'Good script', N'ScreenPlay', CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventRating] ([Id], [EventId], [Rating], [Comments], [Story], [WhyToWatch], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (28, 28, N'85%', N'One Time Watch', N'Good script', N'ScreenPlay', CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventRating] ([Id], [EventId], [Rating], [Comments], [Story], [WhyToWatch], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (29, 29, N'85%', N'One Time Watch', N'Good script', N'ScreenPlay', CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventRating] ([Id], [EventId], [Rating], [Comments], [Story], [WhyToWatch], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (30, 30, N'85%', N'One Time Watch', N'Good script', N'ScreenPlay', CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventRating] ([Id], [EventId], [Rating], [Comments], [Story], [WhyToWatch], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (31, 31, N'85%', N'One Time Watch', N'Good script', N'ScreenPlay', CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventRating] ([Id], [EventId], [Rating], [Comments], [Story], [WhyToWatch], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (32, 32, N'85%', N'One Time Watch', N'Good script', N'ScreenPlay', CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventRating] ([Id], [EventId], [Rating], [Comments], [Story], [WhyToWatch], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (33, 33, N'85%', N'One Time Watch', N'Good script', N'ScreenPlay', CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventRating] ([Id], [EventId], [Rating], [Comments], [Story], [WhyToWatch], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (34, 34, N'85%', N'One Time Watch', N'Good script', N'ScreenPlay', CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventRating] ([Id], [EventId], [Rating], [Comments], [Story], [WhyToWatch], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (35, 35, N'85%', N'One Time Watch', N'Good script', N'ScreenPlay', CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventRating] ([Id], [EventId], [Rating], [Comments], [Story], [WhyToWatch], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (36, 36, N'85%', N'One Time Watch', N'Good script', N'ScreenPlay', CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventRating] ([Id], [EventId], [Rating], [Comments], [Story], [WhyToWatch], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (37, 37, N'85%', N'One Time Watch', N'Good script', N'ScreenPlay', CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventRating] ([Id], [EventId], [Rating], [Comments], [Story], [WhyToWatch], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (38, 38, N'85%', N'One Time Watch', N'Good script', N'ScreenPlay', CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventRating] ([Id], [EventId], [Rating], [Comments], [Story], [WhyToWatch], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (39, 39, N'85%', N'One Time Watch', N'Good script', N'ScreenPlay', CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventRating] ([Id], [EventId], [Rating], [Comments], [Story], [WhyToWatch], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (40, 40, N'85%', N'One Time Watch', N'Good script', N'ScreenPlay', CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventRating] ([Id], [EventId], [Rating], [Comments], [Story], [WhyToWatch], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (41, 41, N'85%', N'One Time Watch', N'Good script', N'ScreenPlay', CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventRating] ([Id], [EventId], [Rating], [Comments], [Story], [WhyToWatch], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (42, 42, N'85%', N'One Time Watch', N'Good script', N'ScreenPlay', CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventRating] ([Id], [EventId], [Rating], [Comments], [Story], [WhyToWatch], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (43, 43, N'85%', N'One Time Watch', N'Good script', N'ScreenPlay', CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventRating] ([Id], [EventId], [Rating], [Comments], [Story], [WhyToWatch], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (44, 44, N'85%', N'One Time Watch', N'Good script', N'ScreenPlay', CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventRating] ([Id], [EventId], [Rating], [Comments], [Story], [WhyToWatch], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (45, 45, N'85%', N'One Time Watch', N'Good script', N'ScreenPlay', CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventRating] ([Id], [EventId], [Rating], [Comments], [Story], [WhyToWatch], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (46, 46, N'85%', N'One Time Watch', N'Good script', N'ScreenPlay', CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventRating] ([Id], [EventId], [Rating], [Comments], [Story], [WhyToWatch], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (47, 47, N'85%', N'One Time Watch', N'Good script', N'ScreenPlay', CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventRating] ([Id], [EventId], [Rating], [Comments], [Story], [WhyToWatch], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (48, 48, N'85%', N'One Time Watch', N'Good script', N'ScreenPlay', CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventRating] ([Id], [EventId], [Rating], [Comments], [Story], [WhyToWatch], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (49, 49, N'85%', N'One Time Watch', N'Good script', N'ScreenPlay', CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventRating] ([Id], [EventId], [Rating], [Comments], [Story], [WhyToWatch], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (50, 50, N'85%', N'One Time Watch', N'Good script', N'ScreenPlay', CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventRating] ([Id], [EventId], [Rating], [Comments], [Story], [WhyToWatch], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (51, 51, N'85%', N'One Time Watch', N'Good script', N'ScreenPlay', CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventRating] ([Id], [EventId], [Rating], [Comments], [Story], [WhyToWatch], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (52, 52, N'85%', N'One Time Watch', N'Good script', N'ScreenPlay', CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventRating] ([Id], [EventId], [Rating], [Comments], [Story], [WhyToWatch], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (53, 53, N'85%', N'One Time Watch', N'Good script', N'ScreenPlay', CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventRating] ([Id], [EventId], [Rating], [Comments], [Story], [WhyToWatch], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (54, 54, N'85%', N'One Time Watch', N'Good script', N'ScreenPlay', CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventRating] ([Id], [EventId], [Rating], [Comments], [Story], [WhyToWatch], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (55, 55, N'85%', N'One Time Watch', N'Good script', N'ScreenPlay', CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventRating] ([Id], [EventId], [Rating], [Comments], [Story], [WhyToWatch], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (56, 56, N'85%', N'One Time Watch', N'Good script', N'ScreenPlay', CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventRating] ([Id], [EventId], [Rating], [Comments], [Story], [WhyToWatch], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (57, 57, N'85%', N'One Time Watch', N'Good script', N'ScreenPlay', CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventRating] ([Id], [EventId], [Rating], [Comments], [Story], [WhyToWatch], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (58, 58, N'85%', N'One Time Watch', N'Good script', N'ScreenPlay', CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventRating] ([Id], [EventId], [Rating], [Comments], [Story], [WhyToWatch], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (59, 59, N'85%', N'One Time Watch', N'Good script', N'ScreenPlay', CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventRating] ([Id], [EventId], [Rating], [Comments], [Story], [WhyToWatch], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (60, 60, N'85%', N'One Time Watch', N'Good script', N'ScreenPlay', CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventRating] ([Id], [EventId], [Rating], [Comments], [Story], [WhyToWatch], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (61, 61, N'85%', N'One Time Watch', N'Good script', N'ScreenPlay', CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventRating] ([Id], [EventId], [Rating], [Comments], [Story], [WhyToWatch], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (62, 62, N'85%', N'One Time Watch', N'Good script', N'ScreenPlay', CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventRating] ([Id], [EventId], [Rating], [Comments], [Story], [WhyToWatch], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (63, 63, N'85%', N'One Time Watch', N'Good script', N'ScreenPlay', CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventRating] ([Id], [EventId], [Rating], [Comments], [Story], [WhyToWatch], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (64, 64, N'85%', N'One Time Watch', N'Good script', N'ScreenPlay', CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventRating] ([Id], [EventId], [Rating], [Comments], [Story], [WhyToWatch], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (65, 65, N'85%', N'One Time Watch', N'Good script', N'ScreenPlay', CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventRating] ([Id], [EventId], [Rating], [Comments], [Story], [WhyToWatch], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (66, 66, N'85%', N'One Time Watch', N'Good script', N'ScreenPlay', CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventRating] ([Id], [EventId], [Rating], [Comments], [Story], [WhyToWatch], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (67, 67, N'85%', N'One Time Watch', N'Good script', N'ScreenPlay', CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventRating] ([Id], [EventId], [Rating], [Comments], [Story], [WhyToWatch], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (68, 68, N'85%', N'One Time Watch', N'Good script', N'ScreenPlay', CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventRating] ([Id], [EventId], [Rating], [Comments], [Story], [WhyToWatch], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (69, 69, N'85%', N'One Time Watch', N'Good script', N'ScreenPlay', CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
INSERT [dbo].[EventRating] ([Id], [EventId], [Rating], [Comments], [Story], [WhyToWatch], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifedBy]) VALUES (70, 70, N'85%', N'One Time Watch', N'Good script', N'ScreenPlay', CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date), N'ADMIN', N'ADMIN')
GO
SET IDENTITY_INSERT [dbo].[EventRating] OFF
GO
SET IDENTITY_INSERT [dbo].[MasterData] ON 

GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1, N'COUNTRIES_ALPHACODE_NAME', N'AF', N'Afghanistan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (2, N'COUNTRIES_ALPHACODE_NAME', N'AL', N'Albania', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (3, N'COUNTRIES_ALPHACODE_NAME', N'DZ', N'Algeria', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (4, N'COUNTRIES_ALPHACODE_NAME', N'AS', N'American Samoa', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (5, N'COUNTRIES_ALPHACODE_NAME', N'AD', N'Andorra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (6, N'COUNTRIES_ALPHACODE_NAME', N'AO', N'Angola', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (7, N'COUNTRIES_ALPHACODE_NAME', N'AI', N'Anguilla', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (8, N'COUNTRIES_ALPHACODE_NAME', N'AQ', N'Antarctica', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (9, N'COUNTRIES_ALPHACODE_NAME', N'AG', N'Antigua and Barbuda', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (10, N'COUNTRIES_ALPHACODE_NAME', N'AR', N'Argentina', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (11, N'COUNTRIES_ALPHACODE_NAME', N'AM', N'Armenia', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (12, N'COUNTRIES_ALPHACODE_NAME', N'AW', N'Aruba', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (13, N'COUNTRIES_ALPHACODE_NAME', N'AU', N'Australia', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (14, N'COUNTRIES_ALPHACODE_NAME', N'AT', N'Austria', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (15, N'COUNTRIES_ALPHACODE_NAME', N'AZ', N'Azerbaijan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (16, N'COUNTRIES_ALPHACODE_NAME', N'BS', N'Bahamas (the)', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (17, N'COUNTRIES_ALPHACODE_NAME', N'BH', N'Bahrain', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (18, N'COUNTRIES_ALPHACODE_NAME', N'BD', N'Bangladesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (19, N'COUNTRIES_ALPHACODE_NAME', N'BB', N'Barbados', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (20, N'COUNTRIES_ALPHACODE_NAME', N'BY', N'Belarus', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (21, N'COUNTRIES_ALPHACODE_NAME', N'BE', N'Belgium', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (22, N'COUNTRIES_ALPHACODE_NAME', N'BZ', N'Belize', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (23, N'COUNTRIES_ALPHACODE_NAME', N'BJ', N'Benin', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (24, N'COUNTRIES_ALPHACODE_NAME', N'BM', N'Bermuda', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (25, N'COUNTRIES_ALPHACODE_NAME', N'BT', N'Bhutan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (26, N'COUNTRIES_ALPHACODE_NAME', N'BO', N'Bolivia (Plurinational State of)', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (27, N'COUNTRIES_ALPHACODE_NAME', N'BQ', N'Bonaire, Sint Eustatius and Saba', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (28, N'COUNTRIES_ALPHACODE_NAME', N'BA', N'Bosnia and Herzegovina', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (29, N'COUNTRIES_ALPHACODE_NAME', N'BW', N'Botswana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (30, N'COUNTRIES_ALPHACODE_NAME', N'BV', N'Bouvet Island', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (31, N'COUNTRIES_ALPHACODE_NAME', N'BR', N'Brazil', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (32, N'COUNTRIES_ALPHACODE_NAME', N'IO', N'British Indian Ocean Territory (the)', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (33, N'COUNTRIES_ALPHACODE_NAME', N'BN', N'Brunei Darussalam', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (34, N'COUNTRIES_ALPHACODE_NAME', N'BG', N'Bulgaria', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (35, N'COUNTRIES_ALPHACODE_NAME', N'BF', N'Burkina Faso', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (36, N'COUNTRIES_ALPHACODE_NAME', N'BI', N'Burundi', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (37, N'COUNTRIES_ALPHACODE_NAME', N'CV', N'Cabo Verde', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (38, N'COUNTRIES_ALPHACODE_NAME', N'KH', N'Cambodia', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (39, N'COUNTRIES_ALPHACODE_NAME', N'CM', N'Cameroon', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (40, N'COUNTRIES_ALPHACODE_NAME', N'CA', N'Canada', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (41, N'COUNTRIES_ALPHACODE_NAME', N'KY', N'Cayman Islands (the)', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (42, N'COUNTRIES_ALPHACODE_NAME', N'CF', N'Central African Republic (the)', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (43, N'COUNTRIES_ALPHACODE_NAME', N'TD', N'Chad', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (44, N'COUNTRIES_ALPHACODE_NAME', N'CL', N'Chile', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (45, N'COUNTRIES_ALPHACODE_NAME', N'CN', N'China', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (46, N'COUNTRIES_ALPHACODE_NAME', N'CX', N'Christmas Island', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (47, N'COUNTRIES_ALPHACODE_NAME', N'CC', N'Cocos (Keeling) Islands (the)', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (48, N'COUNTRIES_ALPHACODE_NAME', N'CO', N'Colombia', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (49, N'COUNTRIES_ALPHACODE_NAME', N'KM', N'Comoros (the)', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (50, N'COUNTRIES_ALPHACODE_NAME', N'CD', N'Congo (the Democratic Republic of the)', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (51, N'COUNTRIES_ALPHACODE_NAME', N'CG', N'Congo (the)', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (52, N'COUNTRIES_ALPHACODE_NAME', N'CK', N'Cook Islands (the)', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (53, N'COUNTRIES_ALPHACODE_NAME', N'CR', N'Costa Rica', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (54, N'COUNTRIES_ALPHACODE_NAME', N'HR', N'Croatia', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (55, N'COUNTRIES_ALPHACODE_NAME', N'CU', N'Cuba', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (56, N'COUNTRIES_ALPHACODE_NAME', N'CW', N'Curaçao', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (57, N'COUNTRIES_ALPHACODE_NAME', N'CY', N'Cyprus', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (58, N'COUNTRIES_ALPHACODE_NAME', N'CZ', N'Czechia', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (59, N'COUNTRIES_ALPHACODE_NAME', N'CI', N'Côte d''Ivoire', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (60, N'COUNTRIES_ALPHACODE_NAME', N'DK', N'Denmark', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (61, N'COUNTRIES_ALPHACODE_NAME', N'DJ', N'Djibouti', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (62, N'COUNTRIES_ALPHACODE_NAME', N'DM', N'Dominica', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (63, N'COUNTRIES_ALPHACODE_NAME', N'DO', N'Dominican Republic (the)', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (64, N'COUNTRIES_ALPHACODE_NAME', N'EC', N'Ecuador', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (65, N'COUNTRIES_ALPHACODE_NAME', N'EG', N'Egypt', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (66, N'COUNTRIES_ALPHACODE_NAME', N'SV', N'El Salvador', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (67, N'COUNTRIES_ALPHACODE_NAME', N'GQ', N'Equatorial Guinea', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (68, N'COUNTRIES_ALPHACODE_NAME', N'ER', N'Eritrea', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (69, N'COUNTRIES_ALPHACODE_NAME', N'EE', N'Estonia', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (70, N'COUNTRIES_ALPHACODE_NAME', N'SZ', N'Eswatini', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (71, N'COUNTRIES_ALPHACODE_NAME', N'ET', N'Ethiopia', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (72, N'COUNTRIES_ALPHACODE_NAME', N'FK', N'Falkland Islands (the) [Malvinas]', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (73, N'COUNTRIES_ALPHACODE_NAME', N'FO', N'Faroe Islands (the)', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (74, N'COUNTRIES_ALPHACODE_NAME', N'FJ', N'Fiji', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (75, N'COUNTRIES_ALPHACODE_NAME', N'FI', N'Finland', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (76, N'COUNTRIES_ALPHACODE_NAME', N'FR', N'France', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (77, N'COUNTRIES_ALPHACODE_NAME', N'GF', N'French Guiana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (78, N'COUNTRIES_ALPHACODE_NAME', N'PF', N'French Polynesia', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (79, N'COUNTRIES_ALPHACODE_NAME', N'TF', N'French Southern Territories (the)', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (80, N'COUNTRIES_ALPHACODE_NAME', N'GA', N'Gabon', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (81, N'COUNTRIES_ALPHACODE_NAME', N'GM', N'Gambia (the)', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (82, N'COUNTRIES_ALPHACODE_NAME', N'GE', N'Georgia', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (83, N'COUNTRIES_ALPHACODE_NAME', N'DE', N'Germany', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (84, N'COUNTRIES_ALPHACODE_NAME', N'GH', N'Ghana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (85, N'COUNTRIES_ALPHACODE_NAME', N'GI', N'Gibraltar', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (86, N'COUNTRIES_ALPHACODE_NAME', N'GR', N'Greece', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (87, N'COUNTRIES_ALPHACODE_NAME', N'GL', N'Greenland', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (88, N'COUNTRIES_ALPHACODE_NAME', N'GD', N'Grenada', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (89, N'COUNTRIES_ALPHACODE_NAME', N'GP', N'Guadeloupe', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (90, N'COUNTRIES_ALPHACODE_NAME', N'GU', N'Guam', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (91, N'COUNTRIES_ALPHACODE_NAME', N'GT', N'Guatemala', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (92, N'COUNTRIES_ALPHACODE_NAME', N'GG', N'Guernsey', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (93, N'COUNTRIES_ALPHACODE_NAME', N'GN', N'Guinea', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (94, N'COUNTRIES_ALPHACODE_NAME', N'GW', N'Guinea-Bissau', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (95, N'COUNTRIES_ALPHACODE_NAME', N'GY', N'Guyana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (96, N'COUNTRIES_ALPHACODE_NAME', N'HT', N'Haiti', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (97, N'COUNTRIES_ALPHACODE_NAME', N'HM', N'Heard Island and McDonald Islands', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (98, N'COUNTRIES_ALPHACODE_NAME', N'VA', N'Holy See (the)', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (99, N'COUNTRIES_ALPHACODE_NAME', N'HN', N'Honduras', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (100, N'COUNTRIES_ALPHACODE_NAME', N'HK', N'Hong Kong', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (101, N'COUNTRIES_ALPHACODE_NAME', N'HU', N'Hungary', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (102, N'COUNTRIES_ALPHACODE_NAME', N'IS', N'Iceland', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (103, N'COUNTRIES_ALPHACODE_NAME', N'IN', N'India', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (104, N'COUNTRIES_ALPHACODE_NAME', N'ID', N'Indonesia', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (105, N'COUNTRIES_ALPHACODE_NAME', N'IR', N'Iran (Islamic Republic of)', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (106, N'COUNTRIES_ALPHACODE_NAME', N'IQ', N'Iraq', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (107, N'COUNTRIES_ALPHACODE_NAME', N'IE', N'Ireland', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (108, N'COUNTRIES_ALPHACODE_NAME', N'IM', N'Isle of Man', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (109, N'COUNTRIES_ALPHACODE_NAME', N'IL', N'Israel', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (110, N'COUNTRIES_ALPHACODE_NAME', N'IT', N'Italy', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (111, N'COUNTRIES_ALPHACODE_NAME', N'JM', N'Jamaica', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (112, N'COUNTRIES_ALPHACODE_NAME', N'JP', N'Japan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (113, N'COUNTRIES_ALPHACODE_NAME', N'JE', N'Jersey', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (114, N'COUNTRIES_ALPHACODE_NAME', N'JO', N'Jordan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (115, N'COUNTRIES_ALPHACODE_NAME', N'KZ', N'Kazakhstan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (116, N'COUNTRIES_ALPHACODE_NAME', N'KE', N'Kenya', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (117, N'COUNTRIES_ALPHACODE_NAME', N'KI', N'Kiribati', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (118, N'COUNTRIES_ALPHACODE_NAME', N'KP', N'Korea (the Democratic People''s Republic of)', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (119, N'COUNTRIES_ALPHACODE_NAME', N'KR', N'Korea (the Republic of)', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (120, N'COUNTRIES_ALPHACODE_NAME', N'KW', N'Kuwait', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (121, N'COUNTRIES_ALPHACODE_NAME', N'KG', N'Kyrgyzstan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (122, N'COUNTRIES_ALPHACODE_NAME', N'LA', N'Lao People''s Democratic Republic (the)', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (123, N'COUNTRIES_ALPHACODE_NAME', N'LV', N'Latvia', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (124, N'COUNTRIES_ALPHACODE_NAME', N'LB', N'Lebanon', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (125, N'COUNTRIES_ALPHACODE_NAME', N'LS', N'Lesotho', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (126, N'COUNTRIES_ALPHACODE_NAME', N'LR', N'Liberia', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (127, N'COUNTRIES_ALPHACODE_NAME', N'LY', N'Libya', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (128, N'COUNTRIES_ALPHACODE_NAME', N'LI', N'Liechtenstein', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (129, N'COUNTRIES_ALPHACODE_NAME', N'LT', N'Lithuania', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (130, N'COUNTRIES_ALPHACODE_NAME', N'LU', N'Luxembourg', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (131, N'COUNTRIES_ALPHACODE_NAME', N'MO', N'Macao', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (132, N'COUNTRIES_ALPHACODE_NAME', N'MG', N'Madagascar', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (133, N'COUNTRIES_ALPHACODE_NAME', N'MW', N'Malawi', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (134, N'COUNTRIES_ALPHACODE_NAME', N'MY', N'Malaysia', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (135, N'COUNTRIES_ALPHACODE_NAME', N'MV', N'Maldives', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (136, N'COUNTRIES_ALPHACODE_NAME', N'ML', N'Mali', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (137, N'COUNTRIES_ALPHACODE_NAME', N'MT', N'Malta', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (138, N'COUNTRIES_ALPHACODE_NAME', N'MH', N'Marshall Islands (the)', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (139, N'COUNTRIES_ALPHACODE_NAME', N'MQ', N'Martinique', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (140, N'COUNTRIES_ALPHACODE_NAME', N'MR', N'Mauritania', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (141, N'COUNTRIES_ALPHACODE_NAME', N'MU', N'Mauritius', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (142, N'COUNTRIES_ALPHACODE_NAME', N'YT', N'Mayotte', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (143, N'COUNTRIES_ALPHACODE_NAME', N'MX', N'Mexico', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (144, N'COUNTRIES_ALPHACODE_NAME', N'FM', N'Micronesia (Federated States of)', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (145, N'COUNTRIES_ALPHACODE_NAME', N'MD', N'Moldova (the Republic of)', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (146, N'COUNTRIES_ALPHACODE_NAME', N'MC', N'Monaco', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (147, N'COUNTRIES_ALPHACODE_NAME', N'MN', N'Mongolia', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (148, N'COUNTRIES_ALPHACODE_NAME', N'ME', N'Montenegro', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (149, N'COUNTRIES_ALPHACODE_NAME', N'MS', N'Montserrat', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (150, N'COUNTRIES_ALPHACODE_NAME', N'MA', N'Morocco', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (151, N'COUNTRIES_ALPHACODE_NAME', N'MZ', N'Mozambique', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (152, N'COUNTRIES_ALPHACODE_NAME', N'MM', N'Myanmar', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (153, N'COUNTRIES_ALPHACODE_NAME', N'NA', N'Namibia', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (154, N'COUNTRIES_ALPHACODE_NAME', N'NR', N'Nauru', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (155, N'COUNTRIES_ALPHACODE_NAME', N'NP', N'Nepal', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (156, N'COUNTRIES_ALPHACODE_NAME', N'NL', N'Netherlands (the)', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (157, N'COUNTRIES_ALPHACODE_NAME', N'NC', N'New Caledonia', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (158, N'COUNTRIES_ALPHACODE_NAME', N'NZ', N'New Zealand', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (159, N'COUNTRIES_ALPHACODE_NAME', N'NI', N'Nicaragua', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (160, N'COUNTRIES_ALPHACODE_NAME', N'NE', N'Niger (the)', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (161, N'COUNTRIES_ALPHACODE_NAME', N'NG', N'Nigeria', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (162, N'COUNTRIES_ALPHACODE_NAME', N'NU', N'Niue', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (163, N'COUNTRIES_ALPHACODE_NAME', N'NF', N'Norfolk Island', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (164, N'COUNTRIES_ALPHACODE_NAME', N'MP', N'Northern Mariana Islands (the)', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (165, N'COUNTRIES_ALPHACODE_NAME', N'NO', N'Norway', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (166, N'COUNTRIES_ALPHACODE_NAME', N'OM', N'Oman', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (167, N'COUNTRIES_ALPHACODE_NAME', N'PK', N'Pakistan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (168, N'COUNTRIES_ALPHACODE_NAME', N'PW', N'Palau', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (169, N'COUNTRIES_ALPHACODE_NAME', N'PS', N'Palestine, State of', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (170, N'COUNTRIES_ALPHACODE_NAME', N'PA', N'Panama', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (171, N'COUNTRIES_ALPHACODE_NAME', N'PG', N'Papua New Guinea', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (172, N'COUNTRIES_ALPHACODE_NAME', N'PY', N'Paraguay', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (173, N'COUNTRIES_ALPHACODE_NAME', N'PE', N'Peru', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (174, N'COUNTRIES_ALPHACODE_NAME', N'PH', N'Philippines (the)', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (175, N'COUNTRIES_ALPHACODE_NAME', N'PN', N'Pitcairn', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (176, N'COUNTRIES_ALPHACODE_NAME', N'PL', N'Poland', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (177, N'COUNTRIES_ALPHACODE_NAME', N'PT', N'Portugal', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (178, N'COUNTRIES_ALPHACODE_NAME', N'PR', N'Puerto Rico', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (179, N'COUNTRIES_ALPHACODE_NAME', N'QA', N'Qatar', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (180, N'COUNTRIES_ALPHACODE_NAME', N'MK', N'Republic of North Macedonia', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (181, N'COUNTRIES_ALPHACODE_NAME', N'RO', N'Romania', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (182, N'COUNTRIES_ALPHACODE_NAME', N'RU', N'Russian Federation (the)', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (183, N'COUNTRIES_ALPHACODE_NAME', N'RW', N'Rwanda', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (184, N'COUNTRIES_ALPHACODE_NAME', N'RE', N'Réunion', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (185, N'COUNTRIES_ALPHACODE_NAME', N'BL', N'Saint Barthélemy', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (186, N'COUNTRIES_ALPHACODE_NAME', N'SH', N'Saint Helena, Ascension and Tristan da Cunha', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (187, N'COUNTRIES_ALPHACODE_NAME', N'KN', N'Saint Kitts and Nevis', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (188, N'COUNTRIES_ALPHACODE_NAME', N'LC', N'Saint Lucia', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (189, N'COUNTRIES_ALPHACODE_NAME', N'MF', N'Saint Martin (French part)', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (190, N'COUNTRIES_ALPHACODE_NAME', N'PM', N'Saint Pierre and Miquelon', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (191, N'COUNTRIES_ALPHACODE_NAME', N'VC', N'Saint Vincent and the Grenadines', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (192, N'COUNTRIES_ALPHACODE_NAME', N'WS', N'Samoa', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (193, N'COUNTRIES_ALPHACODE_NAME', N'SM', N'San Marino', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (194, N'COUNTRIES_ALPHACODE_NAME', N'ST', N'Sao Tome and Principe', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (195, N'COUNTRIES_ALPHACODE_NAME', N'SA', N'Saudi Arabia', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (196, N'COUNTRIES_ALPHACODE_NAME', N'SN', N'Senegal', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (197, N'COUNTRIES_ALPHACODE_NAME', N'RS', N'Serbia', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (198, N'COUNTRIES_ALPHACODE_NAME', N'SC', N'Seychelles', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (199, N'COUNTRIES_ALPHACODE_NAME', N'SL', N'Sierra Leone', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (200, N'COUNTRIES_ALPHACODE_NAME', N'SG', N'Singapore', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (201, N'COUNTRIES_ALPHACODE_NAME', N'SX', N'Sint Maarten (Dutch part)', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (202, N'COUNTRIES_ALPHACODE_NAME', N'SK', N'Slovakia', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (203, N'COUNTRIES_ALPHACODE_NAME', N'SI', N'Slovenia', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (204, N'COUNTRIES_ALPHACODE_NAME', N'SB', N'Solomon Islands', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (205, N'COUNTRIES_ALPHACODE_NAME', N'SO', N'Somalia', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (206, N'COUNTRIES_ALPHACODE_NAME', N'ZA', N'South Africa', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (207, N'COUNTRIES_ALPHACODE_NAME', N'GS', N'South Georgia and the South Sandwich Islands', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (208, N'COUNTRIES_ALPHACODE_NAME', N'SS', N'South Sudan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (209, N'COUNTRIES_ALPHACODE_NAME', N'ES', N'Spain', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (210, N'COUNTRIES_ALPHACODE_NAME', N'LK', N'Sri Lanka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (211, N'COUNTRIES_ALPHACODE_NAME', N'SD', N'Sudan (the)', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (212, N'COUNTRIES_ALPHACODE_NAME', N'SR', N'Suriname', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (213, N'COUNTRIES_ALPHACODE_NAME', N'SJ', N'Svalbard and Jan Mayen', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (214, N'COUNTRIES_ALPHACODE_NAME', N'SE', N'Sweden', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (215, N'COUNTRIES_ALPHACODE_NAME', N'CH', N'Switzerland', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (216, N'COUNTRIES_ALPHACODE_NAME', N'SY', N'Syrian Arab Republic', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (217, N'COUNTRIES_ALPHACODE_NAME', N'TW', N'Taiwan (Province of China)', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (218, N'COUNTRIES_ALPHACODE_NAME', N'TJ', N'Tajikistan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (219, N'COUNTRIES_ALPHACODE_NAME', N'TZ', N'Tanzania, United Republic of', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (220, N'COUNTRIES_ALPHACODE_NAME', N'TH', N'Thailand', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (221, N'COUNTRIES_ALPHACODE_NAME', N'TL', N'Timor-Leste', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (222, N'COUNTRIES_ALPHACODE_NAME', N'TG', N'Togo', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (223, N'COUNTRIES_ALPHACODE_NAME', N'TK', N'Tokelau', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (224, N'COUNTRIES_ALPHACODE_NAME', N'TO', N'Tonga', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (225, N'COUNTRIES_ALPHACODE_NAME', N'TT', N'Trinidad and Tobago', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (226, N'COUNTRIES_ALPHACODE_NAME', N'TN', N'Tunisia', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (227, N'COUNTRIES_ALPHACODE_NAME', N'TR', N'Turkey', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (228, N'COUNTRIES_ALPHACODE_NAME', N'TM', N'Turkmenistan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (229, N'COUNTRIES_ALPHACODE_NAME', N'TC', N'Turks and Caicos Islands (the)', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (230, N'COUNTRIES_ALPHACODE_NAME', N'TV', N'Tuvalu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (231, N'COUNTRIES_ALPHACODE_NAME', N'UG', N'Uganda', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (232, N'COUNTRIES_ALPHACODE_NAME', N'UA', N'Ukraine', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (233, N'COUNTRIES_ALPHACODE_NAME', N'AE', N'United Arab Emirates (the)', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (234, N'COUNTRIES_ALPHACODE_NAME', N'GB', N'United Kingdom of Great Britain and Northern Ireland (the)', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (235, N'COUNTRIES_ALPHACODE_NAME', N'UM', N'United States Minor Outlying Islands (the)', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (236, N'COUNTRIES_ALPHACODE_NAME', N'US', N'United States of America (the)', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (237, N'COUNTRIES_ALPHACODE_NAME', N'UY', N'Uruguay', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (238, N'COUNTRIES_ALPHACODE_NAME', N'UZ', N'Uzbekistan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (239, N'COUNTRIES_ALPHACODE_NAME', N'VU', N'Vanuatu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (240, N'COUNTRIES_ALPHACODE_NAME', N'VE', N'Venezuela (Bolivarian Republic of)', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (241, N'COUNTRIES_ALPHACODE_NAME', N'VN', N'Viet Nam', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (242, N'COUNTRIES_ALPHACODE_NAME', N'VG', N'Virgin Islands (British)', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (243, N'COUNTRIES_ALPHACODE_NAME', N'VI', N'Virgin Islands (U.S.)', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (244, N'COUNTRIES_ALPHACODE_NAME', N'WF', N'Wallis and Futuna', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (245, N'COUNTRIES_ALPHACODE_NAME', N'EH', N'Western Sahara', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (246, N'COUNTRIES_ALPHACODE_NAME', N'YE', N'Yemen', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (247, N'COUNTRIES_ALPHACODE_NAME', N'ZM', N'Zambia', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (248, N'COUNTRIES_ALPHACODE_NAME', N'ZW', N'Zimbabwe', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (249, N'COUNTRIES_ALPHACODE_NAME', N'AX', N'Åland Islands', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (250, N'LANGUAGE_CODE_NAME', N'AA', N'Afar', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (251, N'LANGUAGE_CODE_NAME', N'AB', N'Abkhazian', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (252, N'LANGUAGE_CODE_NAME', N'AE', N'Avestan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (253, N'LANGUAGE_CODE_NAME', N'AF', N'Afrikaans', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (254, N'LANGUAGE_CODE_NAME', N'AK', N'Akan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (255, N'LANGUAGE_CODE_NAME', N'AM', N'Amharic', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (256, N'LANGUAGE_CODE_NAME', N'AN', N'Aragonese', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (257, N'LANGUAGE_CODE_NAME', N'AR', N'Arabic', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (258, N'LANGUAGE_CODE_NAME', N'AS', N'Assamese', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (259, N'LANGUAGE_CODE_NAME', N'AV', N'Avaric', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (260, N'LANGUAGE_CODE_NAME', N'AY', N'Aymara', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (261, N'LANGUAGE_CODE_NAME', N'AZ', N'Azerbaijani', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (262, N'LANGUAGE_CODE_NAME', N'BA', N'Bashkir', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (263, N'LANGUAGE_CODE_NAME', N'BE', N'Belarusian', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (264, N'LANGUAGE_CODE_NAME', N'BG', N'Bulgarian', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (265, N'LANGUAGE_CODE_NAME', N'BH', N'Bihari languages', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (266, N'LANGUAGE_CODE_NAME', N'BM', N'Bambara', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (267, N'LANGUAGE_CODE_NAME', N'BI', N'Bislama', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (268, N'LANGUAGE_CODE_NAME', N'BN', N'Bengali', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (269, N'LANGUAGE_CODE_NAME', N'BO', N'Tibetan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (270, N'LANGUAGE_CODE_NAME', N'BR', N'Breton', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (271, N'LANGUAGE_CODE_NAME', N'BS', N'Bosnian', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (272, N'LANGUAGE_CODE_NAME', N'CA', N'Catalan; Valencian', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (273, N'LANGUAGE_CODE_NAME', N'CE', N'Chechen', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (274, N'LANGUAGE_CODE_NAME', N'CH', N'Chamorro', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (275, N'LANGUAGE_CODE_NAME', N'CO', N'Corsican', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (276, N'LANGUAGE_CODE_NAME', N'CR', N'Cree', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (277, N'LANGUAGE_CODE_NAME', N'CS', N'Czech', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (278, N'LANGUAGE_CODE_NAME', N'CU', N'Church Slavic; Old Slavonic; Church Slavonic; Old Bulgarian; Old Church Slavonic', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (279, N'LANGUAGE_CODE_NAME', N'CV', N'Chuvash', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (280, N'LANGUAGE_CODE_NAME', N'CY', N'Welsh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (281, N'LANGUAGE_CODE_NAME', N'DA', N'Danish', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (282, N'LANGUAGE_CODE_NAME', N'DE', N'German', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (283, N'LANGUAGE_CODE_NAME', N'DV', N'Divehi; Dhivehi; Maldivian', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (284, N'LANGUAGE_CODE_NAME', N'DZ', N'Dzongkha', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (285, N'LANGUAGE_CODE_NAME', N'EE', N'Ewe', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (286, N'LANGUAGE_CODE_NAME', N'EL', N'Greek, Modern (1453-)', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (287, N'LANGUAGE_CODE_NAME', N'EN', N'English', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (288, N'LANGUAGE_CODE_NAME', N'EO', N'Esperanto', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (289, N'LANGUAGE_CODE_NAME', N'ES', N'Spanish; Castilian', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (290, N'LANGUAGE_CODE_NAME', N'ET', N'Estonian', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (291, N'LANGUAGE_CODE_NAME', N'EU', N'Basque', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (292, N'LANGUAGE_CODE_NAME', N'FA', N'Persian', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (293, N'LANGUAGE_CODE_NAME', N'FF', N'Fulah', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (294, N'LANGUAGE_CODE_NAME', N'FI', N'Finnish', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (295, N'LANGUAGE_CODE_NAME', N'FJ', N'Fijian', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (296, N'LANGUAGE_CODE_NAME', N'FO', N'Faroese', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (297, N'LANGUAGE_CODE_NAME', N'FR', N'French', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (298, N'LANGUAGE_CODE_NAME', N'FY', N'Western Frisian', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (299, N'LANGUAGE_CODE_NAME', N'GA', N'Irish', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (300, N'LANGUAGE_CODE_NAME', N'GD', N'Gaelic; Scottish Gaelic', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (301, N'LANGUAGE_CODE_NAME', N'GL', N'Galician', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (302, N'LANGUAGE_CODE_NAME', N'GN', N'Guarani', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (303, N'LANGUAGE_CODE_NAME', N'GU', N'Gujarati', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (304, N'LANGUAGE_CODE_NAME', N'GV', N'Manx', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (305, N'LANGUAGE_CODE_NAME', N'HA', N'Hausa', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (306, N'LANGUAGE_CODE_NAME', N'HE', N'Hebrew', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (307, N'LANGUAGE_CODE_NAME', N'HI', N'Hindi', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (308, N'LANGUAGE_CODE_NAME', N'HO', N'Hiri Motu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (309, N'LANGUAGE_CODE_NAME', N'HR', N'Croatian', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (310, N'LANGUAGE_CODE_NAME', N'HT', N'Haitian; Haitian Creole', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (311, N'LANGUAGE_CODE_NAME', N'HU', N'Hungarian', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (312, N'LANGUAGE_CODE_NAME', N'HY', N'Armenian', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (313, N'LANGUAGE_CODE_NAME', N'HZ', N'Herero', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (314, N'LANGUAGE_CODE_NAME', N'IA', N'Interlingua (International Auxiliary Language Association)', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (315, N'LANGUAGE_CODE_NAME', N'ID', N'Indonesian', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (316, N'LANGUAGE_CODE_NAME', N'IE', N'Interlingue; Occidental', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (317, N'LANGUAGE_CODE_NAME', N'IG', N'Igbo', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (318, N'LANGUAGE_CODE_NAME', N'II', N'Sichuan Yi; Nuosu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (319, N'LANGUAGE_CODE_NAME', N'IK', N'Inupiaq', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (320, N'LANGUAGE_CODE_NAME', N'IO', N'Ido', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (321, N'LANGUAGE_CODE_NAME', N'IS', N'Icelandic', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (322, N'LANGUAGE_CODE_NAME', N'IT', N'Italian', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (323, N'LANGUAGE_CODE_NAME', N'IU', N'Inuktitut', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (324, N'LANGUAGE_CODE_NAME', N'JA', N'Japanese', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (325, N'LANGUAGE_CODE_NAME', N'JV', N'Javanese', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (326, N'LANGUAGE_CODE_NAME', N'KA', N'Georgian', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (327, N'LANGUAGE_CODE_NAME', N'KG', N'Kongo', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (328, N'LANGUAGE_CODE_NAME', N'KI', N'Kikuyu; Gikuyu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (329, N'LANGUAGE_CODE_NAME', N'KJ', N'Kuanyama; Kwanyama', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (330, N'LANGUAGE_CODE_NAME', N'KK', N'Kazakh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (331, N'LANGUAGE_CODE_NAME', N'KL', N'Kalaallisut; Greenlandic', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (332, N'LANGUAGE_CODE_NAME', N'KM', N'Central Khmer', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (333, N'LANGUAGE_CODE_NAME', N'KN', N'Kannada', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (334, N'LANGUAGE_CODE_NAME', N'KO', N'Korean', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (335, N'LANGUAGE_CODE_NAME', N'KR', N'Kanuri', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (336, N'LANGUAGE_CODE_NAME', N'KS', N'Kashmiri', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (337, N'LANGUAGE_CODE_NAME', N'KU', N'Kurdish', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (338, N'LANGUAGE_CODE_NAME', N'KV', N'Komi', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (339, N'LANGUAGE_CODE_NAME', N'KW', N'Cornish', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (340, N'LANGUAGE_CODE_NAME', N'KY', N'Kirghiz; Kyrgyz', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (341, N'LANGUAGE_CODE_NAME', N'LA', N'Latin', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (342, N'LANGUAGE_CODE_NAME', N'LB', N'Luxembourgish; Letzeburgesch', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (343, N'LANGUAGE_CODE_NAME', N'LG', N'Ganda', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (344, N'LANGUAGE_CODE_NAME', N'LI', N'Limburgan; Limburger; Limburgish', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (345, N'LANGUAGE_CODE_NAME', N'LN', N'Lingala', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (346, N'LANGUAGE_CODE_NAME', N'LO', N'Lao', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (347, N'LANGUAGE_CODE_NAME', N'LT', N'Lithuanian', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (348, N'LANGUAGE_CODE_NAME', N'LU', N'Luba-Katanga', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (349, N'LANGUAGE_CODE_NAME', N'LV', N'Latvian', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (350, N'LANGUAGE_CODE_NAME', N'MG', N'Malagasy', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (351, N'LANGUAGE_CODE_NAME', N'MH', N'Marshallese', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (352, N'LANGUAGE_CODE_NAME', N'MI', N'Maori', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (353, N'LANGUAGE_CODE_NAME', N'MK', N'Macedonian', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (354, N'LANGUAGE_CODE_NAME', N'ML', N'Malayalam', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (355, N'LANGUAGE_CODE_NAME', N'MN', N'Mongolian', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (356, N'LANGUAGE_CODE_NAME', N'MR', N'Marathi', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (357, N'LANGUAGE_CODE_NAME', N'MS', N'Malay', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (358, N'LANGUAGE_CODE_NAME', N'MT', N'Maltese', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (359, N'LANGUAGE_CODE_NAME', N'MY', N'Burmese', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (360, N'LANGUAGE_CODE_NAME', N'NA', N'Nauru', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (361, N'LANGUAGE_CODE_NAME', N'NB', N'Bokmål, Norwegian; Norwegian Bokmål', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (362, N'LANGUAGE_CODE_NAME', N'ND', N'Ndebele, North; North Ndebele', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (363, N'LANGUAGE_CODE_NAME', N'NE', N'Nepali', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (364, N'LANGUAGE_CODE_NAME', N'NG', N'Ndonga', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (365, N'LANGUAGE_CODE_NAME', N'NL', N'Dutch; Flemish', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (366, N'LANGUAGE_CODE_NAME', N'NN', N'Norwegian Nynorsk; Nynorsk, Norwegian', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (367, N'LANGUAGE_CODE_NAME', N'NO', N'Norwegian', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (368, N'LANGUAGE_CODE_NAME', N'NR', N'Ndebele, South; South Ndebele', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (369, N'LANGUAGE_CODE_NAME', N'NV', N'Navajo; Navaho', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (370, N'LANGUAGE_CODE_NAME', N'NY', N'Chichewa; Chewa; Nyanja', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (371, N'LANGUAGE_CODE_NAME', N'OC', N'Occitan (post 1500)', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (372, N'LANGUAGE_CODE_NAME', N'OJ', N'Ojibwa', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (373, N'LANGUAGE_CODE_NAME', N'OM', N'Oromo', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (374, N'LANGUAGE_CODE_NAME', N'OR', N'Oriya', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (375, N'LANGUAGE_CODE_NAME', N'OS', N'Ossetian; Ossetic', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (376, N'LANGUAGE_CODE_NAME', N'PA', N'Panjabi; Punjabi', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (377, N'LANGUAGE_CODE_NAME', N'PI', N'Pali', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (378, N'LANGUAGE_CODE_NAME', N'PL', N'Polish', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (379, N'LANGUAGE_CODE_NAME', N'PS', N'Pushto; Pashto', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (380, N'LANGUAGE_CODE_NAME', N'PT', N'Portuguese', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (381, N'LANGUAGE_CODE_NAME', N'QU', N'Quechua', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (382, N'LANGUAGE_CODE_NAME', N'RM', N'Romansh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (383, N'LANGUAGE_CODE_NAME', N'RN', N'Rundi', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (384, N'LANGUAGE_CODE_NAME', N'RO', N'Romanian; Moldavian; Moldovan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (385, N'LANGUAGE_CODE_NAME', N'RU', N'Russian', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (386, N'LANGUAGE_CODE_NAME', N'RW', N'Kinyarwanda', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (387, N'LANGUAGE_CODE_NAME', N'SA', N'Sanskrit', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (388, N'LANGUAGE_CODE_NAME', N'SC', N'Sardinian', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (389, N'LANGUAGE_CODE_NAME', N'SD', N'Sindhi', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (390, N'LANGUAGE_CODE_NAME', N'SE', N'Northern Sami', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (391, N'LANGUAGE_CODE_NAME', N'SG', N'Sango', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (392, N'LANGUAGE_CODE_NAME', N'SI', N'Sinhala; Sinhalese', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (393, N'LANGUAGE_CODE_NAME', N'SK', N'Slovak', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (394, N'LANGUAGE_CODE_NAME', N'SL', N'Slovenian', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (395, N'LANGUAGE_CODE_NAME', N'SM', N'Samoan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (396, N'LANGUAGE_CODE_NAME', N'SN', N'Shona', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (397, N'LANGUAGE_CODE_NAME', N'SO', N'Somali', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (398, N'LANGUAGE_CODE_NAME', N'SQ', N'Albanian', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (399, N'LANGUAGE_CODE_NAME', N'SR', N'Serbian', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (400, N'LANGUAGE_CODE_NAME', N'SS', N'Swati', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (401, N'LANGUAGE_CODE_NAME', N'ST', N'Sotho, Southern', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (402, N'LANGUAGE_CODE_NAME', N'SU', N'Sundanese', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (403, N'LANGUAGE_CODE_NAME', N'SV', N'Swedish', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (404, N'LANGUAGE_CODE_NAME', N'SW', N'Swahili', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (405, N'LANGUAGE_CODE_NAME', N'TA', N'Tamil', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (406, N'LANGUAGE_CODE_NAME', N'TE', N'Telugu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (407, N'LANGUAGE_CODE_NAME', N'TG', N'Tajik', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (408, N'LANGUAGE_CODE_NAME', N'TH', N'Thai', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (409, N'LANGUAGE_CODE_NAME', N'TI', N'Tigrinya', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (410, N'LANGUAGE_CODE_NAME', N'TK', N'Turkmen', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (411, N'LANGUAGE_CODE_NAME', N'TL', N'Tagalog', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (412, N'LANGUAGE_CODE_NAME', N'TN', N'Tswana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (413, N'LANGUAGE_CODE_NAME', N'TO', N'Tonga (Tonga Islands)', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (414, N'LANGUAGE_CODE_NAME', N'TR', N'Turkish', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (415, N'LANGUAGE_CODE_NAME', N'TS', N'Tsonga', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (416, N'LANGUAGE_CODE_NAME', N'TT', N'Tatar', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (417, N'LANGUAGE_CODE_NAME', N'TW', N'Twi', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (418, N'LANGUAGE_CODE_NAME', N'TY', N'Tahitian', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (419, N'LANGUAGE_CODE_NAME', N'UG', N'Uighur; Uyghur', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (420, N'LANGUAGE_CODE_NAME', N'UK', N'Ukrainian', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (421, N'LANGUAGE_CODE_NAME', N'UR', N'Urdu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (422, N'LANGUAGE_CODE_NAME', N'UZ', N'Uzbek', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (423, N'LANGUAGE_CODE_NAME', N'VE', N'Venda', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (424, N'LANGUAGE_CODE_NAME', N'VI', N'Vietnamese', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (425, N'LANGUAGE_CODE_NAME', N'VO', N'Volapük', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (426, N'LANGUAGE_CODE_NAME', N'WA', N'Walloon', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (427, N'LANGUAGE_CODE_NAME', N'WO', N'Wolof', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (428, N'LANGUAGE_CODE_NAME', N'XH', N'Xhosa', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (429, N'LANGUAGE_CODE_NAME', N'YI', N'Yiddish', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (430, N'LANGUAGE_CODE_NAME', N'YO', N'Yoruba', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (431, N'LANGUAGE_CODE_NAME', N'ZA', N'Zhuang; Chuang', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (432, N'LANGUAGE_CODE_NAME', N'ZH', N'Chinese', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (433, N'LANGUAGE_CODE_NAME', N'ZU', N'Zulu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (434, N'INDIA_STATES_CODE_NAME', N'AN', N'Andaman and Nicobar Islands', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (435, N'INDIA_STATES_CODE_NAME', N'AP', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (436, N'INDIA_STATES_CODE_NAME', N'AR', N'Arunachal Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (437, N'INDIA_STATES_CODE_NAME', N'AS', N'Assam', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (438, N'INDIA_STATES_CODE_NAME', N'BR', N'Bihar', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (439, N'INDIA_STATES_CODE_NAME', N'CH', N'Chandigarh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (440, N'INDIA_STATES_CODE_NAME', N'CT', N'Chhattisgarh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (441, N'INDIA_STATES_CODE_NAME', N'DN', N'Dadra and Nagar Haveli', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (442, N'INDIA_STATES_CODE_NAME', N'DD', N'Daman and Diu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (443, N'INDIA_STATES_CODE_NAME', N'DL', N'Delhi', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (444, N'INDIA_STATES_CODE_NAME', N'GA', N'Goa', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (445, N'INDIA_STATES_CODE_NAME', N'GJ', N'Gujarat', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (446, N'INDIA_STATES_CODE_NAME', N'HR', N'Haryana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (447, N'INDIA_STATES_CODE_NAME', N'HP', N'Himachal Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (448, N'INDIA_STATES_CODE_NAME', N'JK', N'Jammu and Kashmir', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (449, N'INDIA_STATES_CODE_NAME', N'JH', N'Jharkhand', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (450, N'INDIA_STATES_CODE_NAME', N'KA', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (451, N'INDIA_STATES_CODE_NAME', N'KL', N'Kerala', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (452, N'INDIA_STATES_CODE_NAME', N'LD', N'Lakshadweep', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (453, N'INDIA_STATES_CODE_NAME', N'MP', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (454, N'INDIA_STATES_CODE_NAME', N'MH', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (455, N'INDIA_STATES_CODE_NAME', N'MN', N'Manipur', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (456, N'INDIA_STATES_CODE_NAME', N'ML', N'Meghalaya', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (457, N'INDIA_STATES_CODE_NAME', N'MZ', N'Mizoram', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (458, N'INDIA_STATES_CODE_NAME', N'NL', N'Nagaland', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (459, N'INDIA_STATES_CODE_NAME', N'OR', N'Odisha', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (460, N'INDIA_STATES_CODE_NAME', N'PY', N'Puducherry', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (461, N'INDIA_STATES_CODE_NAME', N'PB', N'Punjab', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (462, N'INDIA_STATES_CODE_NAME', N'RJ', N'Rajasthan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (463, N'INDIA_STATES_CODE_NAME', N'SK', N'Sikkim', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (464, N'INDIA_STATES_CODE_NAME', N'TN', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (465, N'INDIA_STATES_CODE_NAME', N'TG', N'Telangana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (466, N'INDIA_STATES_CODE_NAME', N'TR', N'Tripura', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (467, N'INDIA_STATES_CODE_NAME', N'UP', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (468, N'INDIA_STATES_CODE_NAME', N'UT', N'Uttarakhand', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (469, N'INDIA_STATES_CODE_NAME', N'WB', N'West Bengal', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (470, N'INDIA_CITIES_TOWN_STATE', N'Mumbai', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (471, N'INDIA_CITIES_TOWN_STATE', N'Delhi', N'Delhi', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (472, N'INDIA_CITIES_TOWN_STATE', N'Bengaluru', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (473, N'INDIA_CITIES_TOWN_STATE', N'Ahmedabad', N'Gujarat', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (474, N'INDIA_CITIES_TOWN_STATE', N'Hyderabad', N'Telangana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (475, N'INDIA_CITIES_TOWN_STATE', N'Chennai', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (476, N'INDIA_CITIES_TOWN_STATE', N'Kolkata', N'West Bengal', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (477, N'INDIA_CITIES_TOWN_STATE', N'Pune', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (478, N'INDIA_CITIES_TOWN_STATE', N'Jaipur', N'Rajasthan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (479, N'INDIA_CITIES_TOWN_STATE', N'Surat', N'Gujarat', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (480, N'INDIA_CITIES_TOWN_STATE', N'Lucknow', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (481, N'INDIA_CITIES_TOWN_STATE', N'Kanpur', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (482, N'INDIA_CITIES_TOWN_STATE', N'Nagpur', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (483, N'INDIA_CITIES_TOWN_STATE', N'Patna', N'Bihar', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (484, N'INDIA_CITIES_TOWN_STATE', N'Indore', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (485, N'INDIA_CITIES_TOWN_STATE', N'Thane', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (486, N'INDIA_CITIES_TOWN_STATE', N'Bhopal', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (487, N'INDIA_CITIES_TOWN_STATE', N'Visakhapatnam', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (488, N'INDIA_CITIES_TOWN_STATE', N'Vadodara', N'Gujarat', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (489, N'INDIA_CITIES_TOWN_STATE', N'Firozabad', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (490, N'INDIA_CITIES_TOWN_STATE', N'Ludhiana', N'Punjab', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (491, N'INDIA_CITIES_TOWN_STATE', N'Rajkot', N'Gujarat', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (492, N'INDIA_CITIES_TOWN_STATE', N'Agra', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (493, N'INDIA_CITIES_TOWN_STATE', N'Siliguri', N'West Bengal', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (494, N'INDIA_CITIES_TOWN_STATE', N'Nashik', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (495, N'INDIA_CITIES_TOWN_STATE', N'Faridabad', N'Haryana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (496, N'INDIA_CITIES_TOWN_STATE', N'Patiala', N'Punjab', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (497, N'INDIA_CITIES_TOWN_STATE', N'Meerut', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (498, N'INDIA_CITIES_TOWN_STATE', N'Kalyan-Dombivali', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (499, N'INDIA_CITIES_TOWN_STATE', N'Vasai-Virar', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (500, N'INDIA_CITIES_TOWN_STATE', N'Varanasi', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (501, N'INDIA_CITIES_TOWN_STATE', N'Srinagar', N'Jammu and Kashmir', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (502, N'INDIA_CITIES_TOWN_STATE', N'Dhanbad', N'Jharkhand', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (503, N'INDIA_CITIES_TOWN_STATE', N'Jodhpur', N'Rajasthan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (504, N'INDIA_CITIES_TOWN_STATE', N'Amritsar', N'Punjab', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (505, N'INDIA_CITIES_TOWN_STATE', N'Raipur', N'Chhattisgarh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (506, N'INDIA_CITIES_TOWN_STATE', N'Allahabad', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (507, N'INDIA_CITIES_TOWN_STATE', N'Coimbatore', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (508, N'INDIA_CITIES_TOWN_STATE', N'Jabalpur', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (509, N'INDIA_CITIES_TOWN_STATE', N'Gwalior', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (510, N'INDIA_CITIES_TOWN_STATE', N'Vijayawada', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (511, N'INDIA_CITIES_TOWN_STATE', N'Madurai', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (512, N'INDIA_CITIES_TOWN_STATE', N'Guwahati', N'Assam', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (513, N'INDIA_CITIES_TOWN_STATE', N'Chandigarh', N'Chandigarh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (514, N'INDIA_CITIES_TOWN_STATE', N'Hubli-Dharwad', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (515, N'INDIA_CITIES_TOWN_STATE', N'Amroha', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (516, N'INDIA_CITIES_TOWN_STATE', N'Moradabad', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (517, N'INDIA_CITIES_TOWN_STATE', N'Gurgaon', N'Haryana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (518, N'INDIA_CITIES_TOWN_STATE', N'Aligarh', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (519, N'INDIA_CITIES_TOWN_STATE', N'Solapur', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (520, N'INDIA_CITIES_TOWN_STATE', N'Ranchi', N'Jharkhand', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (521, N'INDIA_CITIES_TOWN_STATE', N'Jalandhar', N'Punjab', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (522, N'INDIA_CITIES_TOWN_STATE', N'Tiruchirappalli', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (523, N'INDIA_CITIES_TOWN_STATE', N'Bhubaneswar', N'Odisha', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (524, N'INDIA_CITIES_TOWN_STATE', N'Salem', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (525, N'INDIA_CITIES_TOWN_STATE', N'Warangal', N'Telangana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (526, N'INDIA_CITIES_TOWN_STATE', N'Mira-Bhayandar', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (527, N'INDIA_CITIES_TOWN_STATE', N'Thiruvananthapuram', N'Kerala', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (528, N'INDIA_CITIES_TOWN_STATE', N'Bhiwandi', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (529, N'INDIA_CITIES_TOWN_STATE', N'Saharanpur', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (530, N'INDIA_CITIES_TOWN_STATE', N'Guntur', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (531, N'INDIA_CITIES_TOWN_STATE', N'Amravati', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (532, N'INDIA_CITIES_TOWN_STATE', N'Bikaner', N'Rajasthan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (533, N'INDIA_CITIES_TOWN_STATE', N'Noida', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (534, N'INDIA_CITIES_TOWN_STATE', N'Jamshedpur', N'Jharkhand', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (535, N'INDIA_CITIES_TOWN_STATE', N'Bhilai Nagar', N'Chhattisgarh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (536, N'INDIA_CITIES_TOWN_STATE', N'Cuttack', N'Odisha', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (537, N'INDIA_CITIES_TOWN_STATE', N'Kochi', N'Kerala', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (538, N'INDIA_CITIES_TOWN_STATE', N'Udaipur', N'Rajasthan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (539, N'INDIA_CITIES_TOWN_STATE', N'Bhavnagar', N'Gujarat', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (540, N'INDIA_CITIES_TOWN_STATE', N'Dehradun', N'Uttarakhand', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (541, N'INDIA_CITIES_TOWN_STATE', N'Asansol', N'West Bengal', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (542, N'INDIA_CITIES_TOWN_STATE', N'Nanded-Waghala', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (543, N'INDIA_CITIES_TOWN_STATE', N'Ajmer', N'Rajasthan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (544, N'INDIA_CITIES_TOWN_STATE', N'Jamnagar', N'Gujarat', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (545, N'INDIA_CITIES_TOWN_STATE', N'Ujjain', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (546, N'INDIA_CITIES_TOWN_STATE', N'Sangli', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (547, N'INDIA_CITIES_TOWN_STATE', N'Loni', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (548, N'INDIA_CITIES_TOWN_STATE', N'Jhansi', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (549, N'INDIA_CITIES_TOWN_STATE', N'Pondicherry', N'Puducherry', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (550, N'INDIA_CITIES_TOWN_STATE', N'Nellore', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (551, N'INDIA_CITIES_TOWN_STATE', N'Jammu', N'Jammu and Kashmir', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (552, N'INDIA_CITIES_TOWN_STATE', N'Belagavi', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (553, N'INDIA_CITIES_TOWN_STATE', N'Raurkela', N'Odisha', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (554, N'INDIA_CITIES_TOWN_STATE', N'Mangaluru', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (555, N'INDIA_CITIES_TOWN_STATE', N'Tirunelveli', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (556, N'INDIA_CITIES_TOWN_STATE', N'Malegaon', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (557, N'INDIA_CITIES_TOWN_STATE', N'Gaya', N'Bihar', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (558, N'INDIA_CITIES_TOWN_STATE', N'Tiruppur', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (559, N'INDIA_CITIES_TOWN_STATE', N'Davanagere', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (560, N'INDIA_CITIES_TOWN_STATE', N'Kozhikode', N'Kerala', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (561, N'INDIA_CITIES_TOWN_STATE', N'Akola', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (562, N'INDIA_CITIES_TOWN_STATE', N'Kurnool', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (563, N'INDIA_CITIES_TOWN_STATE', N'Bokaro Steel City', N'Jharkhand', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (564, N'INDIA_CITIES_TOWN_STATE', N'Rajahmundry', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (565, N'INDIA_CITIES_TOWN_STATE', N'Ballari', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (566, N'INDIA_CITIES_TOWN_STATE', N'Agartala', N'Tripura', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (567, N'INDIA_CITIES_TOWN_STATE', N'Bhagalpur', N'Bihar', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (568, N'INDIA_CITIES_TOWN_STATE', N'Latur', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (569, N'INDIA_CITIES_TOWN_STATE', N'Dhule', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (570, N'INDIA_CITIES_TOWN_STATE', N'Korba', N'Chhattisgarh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (571, N'INDIA_CITIES_TOWN_STATE', N'Bhilwara', N'Rajasthan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (572, N'INDIA_CITIES_TOWN_STATE', N'Brahmapur', N'Odisha', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (573, N'INDIA_CITIES_TOWN_STATE', N'Mysore', N'Karnatka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (574, N'INDIA_CITIES_TOWN_STATE', N'Muzaffarpur', N'Bihar', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (575, N'INDIA_CITIES_TOWN_STATE', N'Ahmednagar', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (576, N'INDIA_CITIES_TOWN_STATE', N'Kollam', N'Kerala', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (577, N'INDIA_CITIES_TOWN_STATE', N'Raghunathganj', N'West Bengal', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (578, N'INDIA_CITIES_TOWN_STATE', N'Bilaspur', N'Chhattisgarh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (579, N'INDIA_CITIES_TOWN_STATE', N'Shahjahanpur', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (580, N'INDIA_CITIES_TOWN_STATE', N'Thrissur', N'Kerala', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (581, N'INDIA_CITIES_TOWN_STATE', N'Alwar', N'Rajasthan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (582, N'INDIA_CITIES_TOWN_STATE', N'Kakinada', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (583, N'INDIA_CITIES_TOWN_STATE', N'Nizamabad', N'Telangana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (584, N'INDIA_CITIES_TOWN_STATE', N'Sagar', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (585, N'INDIA_CITIES_TOWN_STATE', N'Tumkur', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (586, N'INDIA_CITIES_TOWN_STATE', N'Hisar', N'Haryana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (587, N'INDIA_CITIES_TOWN_STATE', N'Rohtak', N'Haryana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (588, N'INDIA_CITIES_TOWN_STATE', N'Panipat', N'Haryana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (589, N'INDIA_CITIES_TOWN_STATE', N'Darbhanga', N'Bihar', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (590, N'INDIA_CITIES_TOWN_STATE', N'Kharagpur', N'West Bengal', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (591, N'INDIA_CITIES_TOWN_STATE', N'Aizawl', N'Mizoram', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (592, N'INDIA_CITIES_TOWN_STATE', N'Ichalkaranji', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (593, N'INDIA_CITIES_TOWN_STATE', N'Tirupati', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (594, N'INDIA_CITIES_TOWN_STATE', N'Karnal', N'Haryana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (595, N'INDIA_CITIES_TOWN_STATE', N'Bathinda', N'Punjab', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (596, N'INDIA_CITIES_TOWN_STATE', N'Rampur', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (597, N'INDIA_CITIES_TOWN_STATE', N'Shivamogga', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (598, N'INDIA_CITIES_TOWN_STATE', N'Ratlam', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (599, N'INDIA_CITIES_TOWN_STATE', N'Modinagar', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (600, N'INDIA_CITIES_TOWN_STATE', N'Durg', N'Chhattisgarh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (601, N'INDIA_CITIES_TOWN_STATE', N'Shillong', N'Meghalaya', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (602, N'INDIA_CITIES_TOWN_STATE', N'Imphal', N'Manipur', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (603, N'INDIA_CITIES_TOWN_STATE', N'Hapur', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (604, N'INDIA_CITIES_TOWN_STATE', N'Ranipet', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (605, N'INDIA_CITIES_TOWN_STATE', N'Anantapur', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (606, N'INDIA_CITIES_TOWN_STATE', N'Arrah', N'Bihar', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (607, N'INDIA_CITIES_TOWN_STATE', N'Karimnagar', N'Telangana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (608, N'INDIA_CITIES_TOWN_STATE', N'Parbhani', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (609, N'INDIA_CITIES_TOWN_STATE', N'Etawah', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (610, N'INDIA_CITIES_TOWN_STATE', N'Bharatpur', N'Rajasthan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (611, N'INDIA_CITIES_TOWN_STATE', N'Begusarai', N'Bihar', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (612, N'INDIA_CITIES_TOWN_STATE', N'New Delhi', N'Delhi', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (613, N'INDIA_CITIES_TOWN_STATE', N'Chhapra', N'Bihar', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (614, N'INDIA_CITIES_TOWN_STATE', N'Kadapa', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (615, N'INDIA_CITIES_TOWN_STATE', N'Ramagundam', N'Telangana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (616, N'INDIA_CITIES_TOWN_STATE', N'Pali', N'Rajasthan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (617, N'INDIA_CITIES_TOWN_STATE', N'Satna', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (618, N'INDIA_CITIES_TOWN_STATE', N'Vizianagaram', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (619, N'INDIA_CITIES_TOWN_STATE', N'Katihar', N'Bihar', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (620, N'INDIA_CITIES_TOWN_STATE', N'Hardwar', N'Uttarakhand', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (621, N'INDIA_CITIES_TOWN_STATE', N'Sonipat', N'Haryana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (622, N'INDIA_CITIES_TOWN_STATE', N'Nagercoil', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (623, N'INDIA_CITIES_TOWN_STATE', N'Thanjavur', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (624, N'INDIA_CITIES_TOWN_STATE', N'Murwara (Katni)', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (625, N'INDIA_CITIES_TOWN_STATE', N'Naihati', N'West Bengal', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (626, N'INDIA_CITIES_TOWN_STATE', N'Sambhal', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (627, N'INDIA_CITIES_TOWN_STATE', N'Nadiad', N'Gujarat', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (628, N'INDIA_CITIES_TOWN_STATE', N'Yamunanagar', N'Haryana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (629, N'INDIA_CITIES_TOWN_STATE', N'English Bazar', N'West Bengal', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (630, N'INDIA_CITIES_TOWN_STATE', N'Eluru', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (631, N'INDIA_CITIES_TOWN_STATE', N'Munger', N'Bihar', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (632, N'INDIA_CITIES_TOWN_STATE', N'Panchkula', N'Haryana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (633, N'INDIA_CITIES_TOWN_STATE', N'Raayachuru', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (634, N'INDIA_CITIES_TOWN_STATE', N'Panvel', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (635, N'INDIA_CITIES_TOWN_STATE', N'Deoghar', N'Jharkhand', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (636, N'INDIA_CITIES_TOWN_STATE', N'Ongole', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (637, N'INDIA_CITIES_TOWN_STATE', N'Nandyal', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (638, N'INDIA_CITIES_TOWN_STATE', N'Morena', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (639, N'INDIA_CITIES_TOWN_STATE', N'Bhiwani', N'Haryana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (640, N'INDIA_CITIES_TOWN_STATE', N'Porbandar', N'Gujarat', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (641, N'INDIA_CITIES_TOWN_STATE', N'Palakkad', N'Kerala', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (642, N'INDIA_CITIES_TOWN_STATE', N'Anand', N'Gujarat', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (643, N'INDIA_CITIES_TOWN_STATE', N'Purnia', N'Bihar', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (644, N'INDIA_CITIES_TOWN_STATE', N'Baharampur', N'West Bengal', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (645, N'INDIA_CITIES_TOWN_STATE', N'Barmer', N'Rajasthan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (646, N'INDIA_CITIES_TOWN_STATE', N'Morvi', N'Gujarat', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (647, N'INDIA_CITIES_TOWN_STATE', N'Orai', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (648, N'INDIA_CITIES_TOWN_STATE', N'Bahraich', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (649, N'INDIA_CITIES_TOWN_STATE', N'Sikar', N'Rajasthan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (650, N'INDIA_CITIES_TOWN_STATE', N'Vellore', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (651, N'INDIA_CITIES_TOWN_STATE', N'Singrauli', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (652, N'INDIA_CITIES_TOWN_STATE', N'Khammam', N'Telangana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (653, N'INDIA_CITIES_TOWN_STATE', N'Mahesana', N'Gujarat', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (654, N'INDIA_CITIES_TOWN_STATE', N'Silchar', N'Assam', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (655, N'INDIA_CITIES_TOWN_STATE', N'Sambalpur', N'Odisha', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (656, N'INDIA_CITIES_TOWN_STATE', N'Rewa', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (657, N'INDIA_CITIES_TOWN_STATE', N'Unnao', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (658, N'INDIA_CITIES_TOWN_STATE', N'Hugli-Chinsurah', N'West Bengal', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (659, N'INDIA_CITIES_TOWN_STATE', N'Raiganj', N'West Bengal', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (660, N'INDIA_CITIES_TOWN_STATE', N'Phusro', N'Jharkhand', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (661, N'INDIA_CITIES_TOWN_STATE', N'Adityapur', N'Jharkhand', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (662, N'INDIA_CITIES_TOWN_STATE', N'Alappuzha', N'Kerala', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (663, N'INDIA_CITIES_TOWN_STATE', N'Bahadurgarh', N'Haryana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (664, N'INDIA_CITIES_TOWN_STATE', N'Machilipatnam', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (665, N'INDIA_CITIES_TOWN_STATE', N'Rae Bareli', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (666, N'INDIA_CITIES_TOWN_STATE', N'Jalpaiguri', N'West Bengal', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (667, N'INDIA_CITIES_TOWN_STATE', N'Bharuch', N'Gujarat', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (668, N'INDIA_CITIES_TOWN_STATE', N'Pathankot', N'Punjab', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (669, N'INDIA_CITIES_TOWN_STATE', N'Hoshiarpur', N'Punjab', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (670, N'INDIA_CITIES_TOWN_STATE', N'Baramula', N'Jammu and Kashmir', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (671, N'INDIA_CITIES_TOWN_STATE', N'Adoni', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (672, N'INDIA_CITIES_TOWN_STATE', N'Jind', N'Haryana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (673, N'INDIA_CITIES_TOWN_STATE', N'Tonk', N'Rajasthan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (674, N'INDIA_CITIES_TOWN_STATE', N'Tenali', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (675, N'INDIA_CITIES_TOWN_STATE', N'Kancheepuram', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (676, N'INDIA_CITIES_TOWN_STATE', N'Vapi', N'Gujarat', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (677, N'INDIA_CITIES_TOWN_STATE', N'Sirsa', N'Haryana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (678, N'INDIA_CITIES_TOWN_STATE', N'Navsari', N'Gujarat', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (679, N'INDIA_CITIES_TOWN_STATE', N'Mahbubnagar', N'Telangana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (680, N'INDIA_CITIES_TOWN_STATE', N'Puri', N'Odisha', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (681, N'INDIA_CITIES_TOWN_STATE', N'Robertson Pet', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (682, N'INDIA_CITIES_TOWN_STATE', N'Erode', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (683, N'INDIA_CITIES_TOWN_STATE', N'Batala', N'Punjab', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (684, N'INDIA_CITIES_TOWN_STATE', N'Haldwani-cum-Kathgodam', N'Uttarakhand', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (685, N'INDIA_CITIES_TOWN_STATE', N'Vidisha', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (686, N'INDIA_CITIES_TOWN_STATE', N'Saharsa', N'Bihar', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (687, N'INDIA_CITIES_TOWN_STATE', N'Thanesar', N'Haryana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (688, N'INDIA_CITIES_TOWN_STATE', N'Chittoor', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (689, N'INDIA_CITIES_TOWN_STATE', N'Veraval', N'Gujarat', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (690, N'INDIA_CITIES_TOWN_STATE', N'Lakhimpur', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (691, N'INDIA_CITIES_TOWN_STATE', N'Sitapur', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (692, N'INDIA_CITIES_TOWN_STATE', N'Hindupur', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (693, N'INDIA_CITIES_TOWN_STATE', N'Santipur', N'West Bengal', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (694, N'INDIA_CITIES_TOWN_STATE', N'Balurghat', N'West Bengal', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (695, N'INDIA_CITIES_TOWN_STATE', N'Ganjbasoda', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (696, N'INDIA_CITIES_TOWN_STATE', N'Moga', N'Punjab', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (697, N'INDIA_CITIES_TOWN_STATE', N'Proddatur', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (698, N'INDIA_CITIES_TOWN_STATE', N'Srinagar', N'Uttarakhand', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (699, N'INDIA_CITIES_TOWN_STATE', N'Medinipur', N'West Bengal', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (700, N'INDIA_CITIES_TOWN_STATE', N'Habra', N'West Bengal', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (701, N'INDIA_CITIES_TOWN_STATE', N'Sasaram', N'Bihar', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (702, N'INDIA_CITIES_TOWN_STATE', N'Hajipur', N'Bihar', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (703, N'INDIA_CITIES_TOWN_STATE', N'Bhuj', N'Gujarat', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (704, N'INDIA_CITIES_TOWN_STATE', N'Shivpuri', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (705, N'INDIA_CITIES_TOWN_STATE', N'Ranaghat', N'West Bengal', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (706, N'INDIA_CITIES_TOWN_STATE', N'Shimla', N'Himachal Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (707, N'INDIA_CITIES_TOWN_STATE', N'Tiruvannamalai', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (708, N'INDIA_CITIES_TOWN_STATE', N'Kaithal', N'Haryana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (709, N'INDIA_CITIES_TOWN_STATE', N'Rajnandgaon', N'Chhattisgarh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (710, N'INDIA_CITIES_TOWN_STATE', N'Godhra', N'Gujarat', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (711, N'INDIA_CITIES_TOWN_STATE', N'Hazaribag', N'Jharkhand', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (712, N'INDIA_CITIES_TOWN_STATE', N'Bhimavaram', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (713, N'INDIA_CITIES_TOWN_STATE', N'Mandsaur', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (714, N'INDIA_CITIES_TOWN_STATE', N'Dibrugarh', N'Assam', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (715, N'INDIA_CITIES_TOWN_STATE', N'Kolar', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (716, N'INDIA_CITIES_TOWN_STATE', N'Bankura', N'West Bengal', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (717, N'INDIA_CITIES_TOWN_STATE', N'Mandya', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (718, N'INDIA_CITIES_TOWN_STATE', N'Dehri-on-Sone', N'Bihar', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (719, N'INDIA_CITIES_TOWN_STATE', N'Madanapalle', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (720, N'INDIA_CITIES_TOWN_STATE', N'Malerkotla', N'Punjab', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (721, N'INDIA_CITIES_TOWN_STATE', N'Lalitpur', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (722, N'INDIA_CITIES_TOWN_STATE', N'Bettiah', N'Bihar', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (723, N'INDIA_CITIES_TOWN_STATE', N'Pollachi', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (724, N'INDIA_CITIES_TOWN_STATE', N'Khanna', N'Punjab', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (725, N'INDIA_CITIES_TOWN_STATE', N'Neemuch', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (726, N'INDIA_CITIES_TOWN_STATE', N'Palwal', N'Haryana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (727, N'INDIA_CITIES_TOWN_STATE', N'Palanpur', N'Gujarat', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (728, N'INDIA_CITIES_TOWN_STATE', N'Guntakal', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (729, N'INDIA_CITIES_TOWN_STATE', N'Nabadwip', N'West Bengal', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (730, N'INDIA_CITIES_TOWN_STATE', N'Udupi', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (731, N'INDIA_CITIES_TOWN_STATE', N'Jagdalpur', N'Chhattisgarh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (732, N'INDIA_CITIES_TOWN_STATE', N'Motihari', N'Bihar', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (733, N'INDIA_CITIES_TOWN_STATE', N'Pilibhit', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (734, N'INDIA_CITIES_TOWN_STATE', N'Dimapur', N'Nagaland', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (735, N'INDIA_CITIES_TOWN_STATE', N'Mohali', N'Punjab', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (736, N'INDIA_CITIES_TOWN_STATE', N'Sadulpur', N'Rajasthan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (737, N'INDIA_CITIES_TOWN_STATE', N'Rajapalayam', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (738, N'INDIA_CITIES_TOWN_STATE', N'Dharmavaram', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (739, N'INDIA_CITIES_TOWN_STATE', N'Kashipur', N'Uttarakhand', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (740, N'INDIA_CITIES_TOWN_STATE', N'Sivakasi', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (741, N'INDIA_CITIES_TOWN_STATE', N'Darjiling', N'West Bengal', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (742, N'INDIA_CITIES_TOWN_STATE', N'Chikkamagaluru', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (743, N'INDIA_CITIES_TOWN_STATE', N'Gudivada', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (744, N'INDIA_CITIES_TOWN_STATE', N'Baleshwar Town', N'Odisha', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (745, N'INDIA_CITIES_TOWN_STATE', N'Mancherial', N'Telangana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (746, N'INDIA_CITIES_TOWN_STATE', N'Srikakulam', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (747, N'INDIA_CITIES_TOWN_STATE', N'Adilabad', N'Telangana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (748, N'INDIA_CITIES_TOWN_STATE', N'Yavatmal', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (749, N'INDIA_CITIES_TOWN_STATE', N'Barnala', N'Punjab', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (750, N'INDIA_CITIES_TOWN_STATE', N'Nagaon', N'Assam', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (751, N'INDIA_CITIES_TOWN_STATE', N'Narasaraopet', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (752, N'INDIA_CITIES_TOWN_STATE', N'Raigarh', N'Chhattisgarh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (753, N'INDIA_CITIES_TOWN_STATE', N'Roorkee', N'Uttarakhand', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (754, N'INDIA_CITIES_TOWN_STATE', N'Valsad', N'Gujarat', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (755, N'INDIA_CITIES_TOWN_STATE', N'Ambikapur', N'Chhattisgarh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (756, N'INDIA_CITIES_TOWN_STATE', N'Giridih', N'Jharkhand', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (757, N'INDIA_CITIES_TOWN_STATE', N'Chandausi', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (758, N'INDIA_CITIES_TOWN_STATE', N'Purulia', N'West Bengal', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (759, N'INDIA_CITIES_TOWN_STATE', N'Patan', N'Gujarat', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (760, N'INDIA_CITIES_TOWN_STATE', N'Bagaha', N'Bihar', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (761, N'INDIA_CITIES_TOWN_STATE', N'Hardoi ', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (762, N'INDIA_CITIES_TOWN_STATE', N'Achalpur', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (763, N'INDIA_CITIES_TOWN_STATE', N'Osmanabad', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (764, N'INDIA_CITIES_TOWN_STATE', N'Deesa', N'Gujarat', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (765, N'INDIA_CITIES_TOWN_STATE', N'Nandurbar', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (766, N'INDIA_CITIES_TOWN_STATE', N'Azamgarh', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (767, N'INDIA_CITIES_TOWN_STATE', N'Ramgarh', N'Jharkhand', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (768, N'INDIA_CITIES_TOWN_STATE', N'Firozpur', N'Punjab', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (769, N'INDIA_CITIES_TOWN_STATE', N'Baripada Town', N'Odisha', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (770, N'INDIA_CITIES_TOWN_STATE', N'Karwar', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (771, N'INDIA_CITIES_TOWN_STATE', N'Siwan', N'Bihar', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (772, N'INDIA_CITIES_TOWN_STATE', N'Rajampet', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (773, N'INDIA_CITIES_TOWN_STATE', N'Pudukkottai', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (774, N'INDIA_CITIES_TOWN_STATE', N'Anantnag', N'Jammu and Kashmir', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (775, N'INDIA_CITIES_TOWN_STATE', N'Tadpatri', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (776, N'INDIA_CITIES_TOWN_STATE', N'Satara', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (777, N'INDIA_CITIES_TOWN_STATE', N'Bhadrak', N'Odisha', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (778, N'INDIA_CITIES_TOWN_STATE', N'Kishanganj', N'Bihar', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (779, N'INDIA_CITIES_TOWN_STATE', N'Suryapet', N'Telangana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (780, N'INDIA_CITIES_TOWN_STATE', N'Wardha', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (781, N'INDIA_CITIES_TOWN_STATE', N'Ranebennuru', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (782, N'INDIA_CITIES_TOWN_STATE', N'Amreli', N'Gujarat', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (783, N'INDIA_CITIES_TOWN_STATE', N'Neyveli (TS)', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (784, N'INDIA_CITIES_TOWN_STATE', N'Jamalpur', N'Bihar', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (785, N'INDIA_CITIES_TOWN_STATE', N'Marmagao', N'Goa', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (786, N'INDIA_CITIES_TOWN_STATE', N'Udgir', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (787, N'INDIA_CITIES_TOWN_STATE', N'Tadepalligudem', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (788, N'INDIA_CITIES_TOWN_STATE', N'Nagapattinam', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (789, N'INDIA_CITIES_TOWN_STATE', N'Buxar', N'Bihar', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (790, N'INDIA_CITIES_TOWN_STATE', N'Aurangabad', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (791, N'INDIA_CITIES_TOWN_STATE', N'Jehanabad', N'Bihar', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (792, N'INDIA_CITIES_TOWN_STATE', N'Phagwara', N'Punjab', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (793, N'INDIA_CITIES_TOWN_STATE', N'Khair', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (794, N'INDIA_CITIES_TOWN_STATE', N'Sawai Madhopur', N'Rajasthan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (795, N'INDIA_CITIES_TOWN_STATE', N'Kapurthala', N'Punjab', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (796, N'INDIA_CITIES_TOWN_STATE', N'Chilakaluripet', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (797, N'INDIA_CITIES_TOWN_STATE', N'Aurangabad', N'Bihar', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (798, N'INDIA_CITIES_TOWN_STATE', N'Malappuram', N'Kerala', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (799, N'INDIA_CITIES_TOWN_STATE', N'Rewari', N'Haryana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (800, N'INDIA_CITIES_TOWN_STATE', N'Nagaur', N'Rajasthan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (801, N'INDIA_CITIES_TOWN_STATE', N'Sultanpur', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (802, N'INDIA_CITIES_TOWN_STATE', N'Nagda', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (803, N'INDIA_CITIES_TOWN_STATE', N'Port Blair', N'Andaman and Nicobar Islands', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (804, N'INDIA_CITIES_TOWN_STATE', N'Lakhisarai', N'Bihar', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (805, N'INDIA_CITIES_TOWN_STATE', N'Panaji', N'Goa', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (806, N'INDIA_CITIES_TOWN_STATE', N'Tinsukia', N'Assam', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (807, N'INDIA_CITIES_TOWN_STATE', N'Itarsi', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (808, N'INDIA_CITIES_TOWN_STATE', N'Kohima', N'Nagaland', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (809, N'INDIA_CITIES_TOWN_STATE', N'Balangir', N'Odisha', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (810, N'INDIA_CITIES_TOWN_STATE', N'Nawada', N'Bihar', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (811, N'INDIA_CITIES_TOWN_STATE', N'Jharsuguda', N'Odisha', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (812, N'INDIA_CITIES_TOWN_STATE', N'Jagtial', N'Telangana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (813, N'INDIA_CITIES_TOWN_STATE', N'Viluppuram', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (814, N'INDIA_CITIES_TOWN_STATE', N'Amalner', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (815, N'INDIA_CITIES_TOWN_STATE', N'Zirakpur', N'Punjab', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (816, N'INDIA_CITIES_TOWN_STATE', N'Tanda', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (817, N'INDIA_CITIES_TOWN_STATE', N'Tiruchengode', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (818, N'INDIA_CITIES_TOWN_STATE', N'Nagina', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (819, N'INDIA_CITIES_TOWN_STATE', N'Yemmiganur', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (820, N'INDIA_CITIES_TOWN_STATE', N'Vaniyambadi', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (821, N'INDIA_CITIES_TOWN_STATE', N'Sarni', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (822, N'INDIA_CITIES_TOWN_STATE', N'Theni Allinagaram', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (823, N'INDIA_CITIES_TOWN_STATE', N'Margao', N'Goa', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (824, N'INDIA_CITIES_TOWN_STATE', N'Akot', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (825, N'INDIA_CITIES_TOWN_STATE', N'Sehore', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (826, N'INDIA_CITIES_TOWN_STATE', N'Mhow Cantonment', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (827, N'INDIA_CITIES_TOWN_STATE', N'Kot Kapura', N'Punjab', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (828, N'INDIA_CITIES_TOWN_STATE', N'Makrana', N'Rajasthan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (829, N'INDIA_CITIES_TOWN_STATE', N'Pandharpur', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (830, N'INDIA_CITIES_TOWN_STATE', N'Miryalaguda', N'Telangana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (831, N'INDIA_CITIES_TOWN_STATE', N'Shamli', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (832, N'INDIA_CITIES_TOWN_STATE', N'Seoni', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (833, N'INDIA_CITIES_TOWN_STATE', N'Ranibennur', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (834, N'INDIA_CITIES_TOWN_STATE', N'Kadiri', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (835, N'INDIA_CITIES_TOWN_STATE', N'Shrirampur', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (836, N'INDIA_CITIES_TOWN_STATE', N'Rudrapur', N'Uttarakhand', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (837, N'INDIA_CITIES_TOWN_STATE', N'Parli', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (838, N'INDIA_CITIES_TOWN_STATE', N'Najibabad', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (839, N'INDIA_CITIES_TOWN_STATE', N'Nirmal', N'Telangana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (840, N'INDIA_CITIES_TOWN_STATE', N'Udhagamandalam', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (841, N'INDIA_CITIES_TOWN_STATE', N'Shikohabad', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (842, N'INDIA_CITIES_TOWN_STATE', N'Jhumri Tilaiya', N'Jharkhand', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (843, N'INDIA_CITIES_TOWN_STATE', N'Aruppukkottai', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (844, N'INDIA_CITIES_TOWN_STATE', N'Ponnani', N'Kerala', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (845, N'INDIA_CITIES_TOWN_STATE', N'Jamui', N'Bihar', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (846, N'INDIA_CITIES_TOWN_STATE', N'Sitamarhi', N'Bihar', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (847, N'INDIA_CITIES_TOWN_STATE', N'Chirala', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (848, N'INDIA_CITIES_TOWN_STATE', N'Anjar', N'Gujarat', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (849, N'INDIA_CITIES_TOWN_STATE', N'Karaikal', N'Puducherry', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (850, N'INDIA_CITIES_TOWN_STATE', N'Hansi', N'Haryana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (851, N'INDIA_CITIES_TOWN_STATE', N'Anakapalle', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (852, N'INDIA_CITIES_TOWN_STATE', N'Mahasamund', N'Chhattisgarh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (853, N'INDIA_CITIES_TOWN_STATE', N'Faridkot', N'Punjab', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (854, N'INDIA_CITIES_TOWN_STATE', N'Saunda', N'Jharkhand', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (855, N'INDIA_CITIES_TOWN_STATE', N'Dhoraji', N'Gujarat', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (856, N'INDIA_CITIES_TOWN_STATE', N'Paramakudi', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (857, N'INDIA_CITIES_TOWN_STATE', N'Balaghat', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (858, N'INDIA_CITIES_TOWN_STATE', N'Sujangarh', N'Rajasthan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (859, N'INDIA_CITIES_TOWN_STATE', N'Khambhat', N'Gujarat', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (860, N'INDIA_CITIES_TOWN_STATE', N'Muktsar', N'Punjab', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (861, N'INDIA_CITIES_TOWN_STATE', N'Rajpura', N'Punjab', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (862, N'INDIA_CITIES_TOWN_STATE', N'Kavali', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (863, N'INDIA_CITIES_TOWN_STATE', N'Dhamtari', N'Chhattisgarh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (864, N'INDIA_CITIES_TOWN_STATE', N'Ashok Nagar', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (865, N'INDIA_CITIES_TOWN_STATE', N'Sardarshahar', N'Rajasthan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (866, N'INDIA_CITIES_TOWN_STATE', N'Mahuva', N'Gujarat', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (867, N'INDIA_CITIES_TOWN_STATE', N'Bargarh', N'Odisha', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (868, N'INDIA_CITIES_TOWN_STATE', N'Kamareddy', N'Telangana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (869, N'INDIA_CITIES_TOWN_STATE', N'Sahibganj', N'Jharkhand', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (870, N'INDIA_CITIES_TOWN_STATE', N'Kothagudem', N'Telangana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (871, N'INDIA_CITIES_TOWN_STATE', N'Ramanagaram', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (872, N'INDIA_CITIES_TOWN_STATE', N'Gokak', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (873, N'INDIA_CITIES_TOWN_STATE', N'Tikamgarh', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (874, N'INDIA_CITIES_TOWN_STATE', N'Araria', N'Bihar', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (875, N'INDIA_CITIES_TOWN_STATE', N'Rishikesh', N'Uttarakhand', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (876, N'INDIA_CITIES_TOWN_STATE', N'Shahdol', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (877, N'INDIA_CITIES_TOWN_STATE', N'Medininagar (Daltonganj)', N'Jharkhand', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (878, N'INDIA_CITIES_TOWN_STATE', N'Arakkonam', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (879, N'INDIA_CITIES_TOWN_STATE', N'Washim', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (880, N'INDIA_CITIES_TOWN_STATE', N'Sangrur', N'Punjab', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (881, N'INDIA_CITIES_TOWN_STATE', N'Bodhan', N'Telangana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (882, N'INDIA_CITIES_TOWN_STATE', N'Fazilka', N'Punjab', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (883, N'INDIA_CITIES_TOWN_STATE', N'Palacole', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (884, N'INDIA_CITIES_TOWN_STATE', N'Keshod', N'Gujarat', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (885, N'INDIA_CITIES_TOWN_STATE', N'Sullurpeta', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (886, N'INDIA_CITIES_TOWN_STATE', N'Wadhwan', N'Gujarat', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (887, N'INDIA_CITIES_TOWN_STATE', N'Gurdaspur', N'Punjab', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (888, N'INDIA_CITIES_TOWN_STATE', N'Vatakara', N'Kerala', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (889, N'INDIA_CITIES_TOWN_STATE', N'Tura', N'Meghalaya', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (890, N'INDIA_CITIES_TOWN_STATE', N'Narnaul', N'Haryana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (891, N'INDIA_CITIES_TOWN_STATE', N'Kharar', N'Punjab', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (892, N'INDIA_CITIES_TOWN_STATE', N'Yadgir', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (893, N'INDIA_CITIES_TOWN_STATE', N'Ambejogai', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (894, N'INDIA_CITIES_TOWN_STATE', N'Ankleshwar', N'Gujarat', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (895, N'INDIA_CITIES_TOWN_STATE', N'Savarkundla', N'Gujarat', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (896, N'INDIA_CITIES_TOWN_STATE', N'Paradip', N'Odisha', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (897, N'INDIA_CITIES_TOWN_STATE', N'Virudhachalam', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (898, N'INDIA_CITIES_TOWN_STATE', N'Kanhangad', N'Kerala', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (899, N'INDIA_CITIES_TOWN_STATE', N'Kadi', N'Gujarat', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (900, N'INDIA_CITIES_TOWN_STATE', N'Srivilliputhur', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (901, N'INDIA_CITIES_TOWN_STATE', N'Gobindgarh', N'Punjab', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (902, N'INDIA_CITIES_TOWN_STATE', N'Tindivanam', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (903, N'INDIA_CITIES_TOWN_STATE', N'Mansa', N'Punjab', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (904, N'INDIA_CITIES_TOWN_STATE', N'Taliparamba', N'Kerala', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (905, N'INDIA_CITIES_TOWN_STATE', N'Manmad', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (906, N'INDIA_CITIES_TOWN_STATE', N'Tanuku', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (907, N'INDIA_CITIES_TOWN_STATE', N'Rayachoti', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (908, N'INDIA_CITIES_TOWN_STATE', N'Virudhunagar', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (909, N'INDIA_CITIES_TOWN_STATE', N'Koyilandy', N'Kerala', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (910, N'INDIA_CITIES_TOWN_STATE', N'Jorhat', N'Assam', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (911, N'INDIA_CITIES_TOWN_STATE', N'Karur', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (912, N'INDIA_CITIES_TOWN_STATE', N'Valparai', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (913, N'INDIA_CITIES_TOWN_STATE', N'Srikalahasti', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (914, N'INDIA_CITIES_TOWN_STATE', N'Neyyattinkara', N'Kerala', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (915, N'INDIA_CITIES_TOWN_STATE', N'Bapatla', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (916, N'INDIA_CITIES_TOWN_STATE', N'Fatehabad', N'Haryana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (917, N'INDIA_CITIES_TOWN_STATE', N'Malout', N'Punjab', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (918, N'INDIA_CITIES_TOWN_STATE', N'Sankarankovil', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (919, N'INDIA_CITIES_TOWN_STATE', N'Tenkasi', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (920, N'INDIA_CITIES_TOWN_STATE', N'Ratnagiri', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (921, N'INDIA_CITIES_TOWN_STATE', N'Rabkavi Banhatti', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (922, N'INDIA_CITIES_TOWN_STATE', N'Sikandrabad', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (923, N'INDIA_CITIES_TOWN_STATE', N'Chaibasa', N'Jharkhand', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (924, N'INDIA_CITIES_TOWN_STATE', N'Chirmiri', N'Chhattisgarh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (925, N'INDIA_CITIES_TOWN_STATE', N'Palwancha', N'Telangana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (926, N'INDIA_CITIES_TOWN_STATE', N'Bhawanipatna', N'Odisha', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (927, N'INDIA_CITIES_TOWN_STATE', N'Kayamkulam', N'Kerala', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (928, N'INDIA_CITIES_TOWN_STATE', N'Pithampur', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (929, N'INDIA_CITIES_TOWN_STATE', N'Nabha', N'Punjab', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (930, N'INDIA_CITIES_TOWN_STATE', N'Shahabad, Hardoi', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (931, N'INDIA_CITIES_TOWN_STATE', N'Dhenkanal', N'Odisha', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (932, N'INDIA_CITIES_TOWN_STATE', N'Uran Islampur', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (933, N'INDIA_CITIES_TOWN_STATE', N'Gopalganj', N'Bihar', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (934, N'INDIA_CITIES_TOWN_STATE', N'Bongaigaon City', N'Assam', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (935, N'INDIA_CITIES_TOWN_STATE', N'Palani', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (936, N'INDIA_CITIES_TOWN_STATE', N'Pusad', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (937, N'INDIA_CITIES_TOWN_STATE', N'Sopore', N'Jammu and Kashmir', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (938, N'INDIA_CITIES_TOWN_STATE', N'Pilkhuwa', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (939, N'INDIA_CITIES_TOWN_STATE', N'Tarn Taran', N'Punjab', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (940, N'INDIA_CITIES_TOWN_STATE', N'Renukoot', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (941, N'INDIA_CITIES_TOWN_STATE', N'Mandamarri', N'Telangana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (942, N'INDIA_CITIES_TOWN_STATE', N'Shahabad', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (943, N'INDIA_CITIES_TOWN_STATE', N'Barbil', N'Odisha', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (944, N'INDIA_CITIES_TOWN_STATE', N'Koratla', N'Telangana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (945, N'INDIA_CITIES_TOWN_STATE', N'Madhubani', N'Bihar', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (946, N'INDIA_CITIES_TOWN_STATE', N'Arambagh', N'West Bengal', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (947, N'INDIA_CITIES_TOWN_STATE', N'Gohana', N'Haryana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (948, N'INDIA_CITIES_TOWN_STATE', N'Ladnu', N'Rajasthan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (949, N'INDIA_CITIES_TOWN_STATE', N'Pattukkottai', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (950, N'INDIA_CITIES_TOWN_STATE', N'Sirsi', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (951, N'INDIA_CITIES_TOWN_STATE', N'Sircilla', N'Telangana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (952, N'INDIA_CITIES_TOWN_STATE', N'Tamluk', N'West Bengal', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (953, N'INDIA_CITIES_TOWN_STATE', N'Jagraon', N'Punjab', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (954, N'INDIA_CITIES_TOWN_STATE', N'AlipurdUrban Agglomerationr', N'West Bengal', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (955, N'INDIA_CITIES_TOWN_STATE', N'Alirajpur', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (956, N'INDIA_CITIES_TOWN_STATE', N'Tandur', N'Telangana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (957, N'INDIA_CITIES_TOWN_STATE', N'Naidupet', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (958, N'INDIA_CITIES_TOWN_STATE', N'Tirupathur', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (959, N'INDIA_CITIES_TOWN_STATE', N'Tohana', N'Haryana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (960, N'INDIA_CITIES_TOWN_STATE', N'Ratangarh', N'Rajasthan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (961, N'INDIA_CITIES_TOWN_STATE', N'Dhubri', N'Assam', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (962, N'INDIA_CITIES_TOWN_STATE', N'Masaurhi', N'Bihar', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (963, N'INDIA_CITIES_TOWN_STATE', N'Visnagar', N'Gujarat', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (964, N'INDIA_CITIES_TOWN_STATE', N'Vrindavan', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (965, N'INDIA_CITIES_TOWN_STATE', N'Nokha', N'Rajasthan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (966, N'INDIA_CITIES_TOWN_STATE', N'Nagari', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (967, N'INDIA_CITIES_TOWN_STATE', N'Narwana', N'Haryana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (968, N'INDIA_CITIES_TOWN_STATE', N'Ramanathapuram', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (969, N'INDIA_CITIES_TOWN_STATE', N'Ujhani', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (970, N'INDIA_CITIES_TOWN_STATE', N'Samastipur', N'Bihar', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (971, N'INDIA_CITIES_TOWN_STATE', N'Laharpur', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (972, N'INDIA_CITIES_TOWN_STATE', N'Sangamner', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (973, N'INDIA_CITIES_TOWN_STATE', N'Nimbahera', N'Rajasthan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (974, N'INDIA_CITIES_TOWN_STATE', N'Siddipet', N'Telangana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (975, N'INDIA_CITIES_TOWN_STATE', N'Suri', N'West Bengal', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (976, N'INDIA_CITIES_TOWN_STATE', N'Diphu', N'Assam', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (977, N'INDIA_CITIES_TOWN_STATE', N'Jhargram', N'West Bengal', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (978, N'INDIA_CITIES_TOWN_STATE', N'Shirpur-Warwade', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (979, N'INDIA_CITIES_TOWN_STATE', N'Tilhar', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (980, N'INDIA_CITIES_TOWN_STATE', N'Sindhnur', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (981, N'INDIA_CITIES_TOWN_STATE', N'Udumalaipettai', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (982, N'INDIA_CITIES_TOWN_STATE', N'Malkapur', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (983, N'INDIA_CITIES_TOWN_STATE', N'Wanaparthy', N'Telangana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (984, N'INDIA_CITIES_TOWN_STATE', N'Gudur', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (985, N'INDIA_CITIES_TOWN_STATE', N'Kendujhar', N'Odisha', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (986, N'INDIA_CITIES_TOWN_STATE', N'Mandla', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (987, N'INDIA_CITIES_TOWN_STATE', N'Mandi', N'Himachal Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (988, N'INDIA_CITIES_TOWN_STATE', N'Nedumangad', N'Kerala', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (989, N'INDIA_CITIES_TOWN_STATE', N'North Lakhimpur', N'Assam', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (990, N'INDIA_CITIES_TOWN_STATE', N'Vinukonda', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (991, N'INDIA_CITIES_TOWN_STATE', N'Tiptur', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (992, N'INDIA_CITIES_TOWN_STATE', N'Gobichettipalayam', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (993, N'INDIA_CITIES_TOWN_STATE', N'Sunabeda', N'Odisha', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (994, N'INDIA_CITIES_TOWN_STATE', N'Wani', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (995, N'INDIA_CITIES_TOWN_STATE', N'Upleta', N'Gujarat', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (996, N'INDIA_CITIES_TOWN_STATE', N'Narasapuram', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (997, N'INDIA_CITIES_TOWN_STATE', N'Nuzvid', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (998, N'INDIA_CITIES_TOWN_STATE', N'Tezpur', N'Assam', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (999, N'INDIA_CITIES_TOWN_STATE', N'Una', N'Gujarat', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1000, N'INDIA_CITIES_TOWN_STATE', N'Markapur', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1001, N'INDIA_CITIES_TOWN_STATE', N'Sheopur', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1002, N'INDIA_CITIES_TOWN_STATE', N'Thiruvarur', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1003, N'INDIA_CITIES_TOWN_STATE', N'Sidhpur', N'Gujarat', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1004, N'INDIA_CITIES_TOWN_STATE', N'Sahaswan', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1005, N'INDIA_CITIES_TOWN_STATE', N'Suratgarh', N'Rajasthan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1006, N'INDIA_CITIES_TOWN_STATE', N'Shajapur', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1007, N'INDIA_CITIES_TOWN_STATE', N'Rayagada', N'Odisha', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1008, N'INDIA_CITIES_TOWN_STATE', N'Lonavla', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1009, N'INDIA_CITIES_TOWN_STATE', N'Ponnur', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1010, N'INDIA_CITIES_TOWN_STATE', N'Kagaznagar', N'Telangana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1011, N'INDIA_CITIES_TOWN_STATE', N'Gadwal', N'Telangana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1012, N'INDIA_CITIES_TOWN_STATE', N'Bhatapara', N'Chhattisgarh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1013, N'INDIA_CITIES_TOWN_STATE', N'Kandukur', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1014, N'INDIA_CITIES_TOWN_STATE', N'Sangareddy', N'Telangana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1015, N'INDIA_CITIES_TOWN_STATE', N'Unjha', N'Gujarat', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1016, N'INDIA_CITIES_TOWN_STATE', N'Lunglei', N'Mizoram', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1017, N'INDIA_CITIES_TOWN_STATE', N'Karimganj', N'Assam', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1018, N'INDIA_CITIES_TOWN_STATE', N'Kannur', N'Kerala', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1019, N'INDIA_CITIES_TOWN_STATE', N'Bobbili', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1020, N'INDIA_CITIES_TOWN_STATE', N'Mokameh', N'Bihar', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1021, N'INDIA_CITIES_TOWN_STATE', N'Talegaon Dabhade', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1022, N'INDIA_CITIES_TOWN_STATE', N'Anjangaon', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1023, N'INDIA_CITIES_TOWN_STATE', N'Mangrol', N'Gujarat', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1024, N'INDIA_CITIES_TOWN_STATE', N'Sunam', N'Punjab', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1025, N'INDIA_CITIES_TOWN_STATE', N'Gangarampur', N'West Bengal', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1026, N'INDIA_CITIES_TOWN_STATE', N'Thiruvallur', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1027, N'INDIA_CITIES_TOWN_STATE', N'Tirur', N'Kerala', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1028, N'INDIA_CITIES_TOWN_STATE', N'Rath', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1029, N'INDIA_CITIES_TOWN_STATE', N'Jatani', N'Odisha', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1030, N'INDIA_CITIES_TOWN_STATE', N'Viramgam', N'Gujarat', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1031, N'INDIA_CITIES_TOWN_STATE', N'Rajsamand', N'Rajasthan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1032, N'INDIA_CITIES_TOWN_STATE', N'Yanam', N'Puducherry', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1033, N'INDIA_CITIES_TOWN_STATE', N'Kottayam', N'Kerala', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1034, N'INDIA_CITIES_TOWN_STATE', N'Panruti', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1035, N'INDIA_CITIES_TOWN_STATE', N'Dhuri', N'Punjab', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1036, N'INDIA_CITIES_TOWN_STATE', N'Namakkal', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1037, N'INDIA_CITIES_TOWN_STATE', N'Kasaragod', N'Kerala', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1038, N'INDIA_CITIES_TOWN_STATE', N'Modasa', N'Gujarat', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1039, N'INDIA_CITIES_TOWN_STATE', N'Rayadurg', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1040, N'INDIA_CITIES_TOWN_STATE', N'Supaul', N'Bihar', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1041, N'INDIA_CITIES_TOWN_STATE', N'Kunnamkulam', N'Kerala', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1042, N'INDIA_CITIES_TOWN_STATE', N'Umred', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1043, N'INDIA_CITIES_TOWN_STATE', N'Bellampalle', N'Telangana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1044, N'INDIA_CITIES_TOWN_STATE', N'Sibsagar', N'Assam', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1045, N'INDIA_CITIES_TOWN_STATE', N'Mandi Dabwali', N'Haryana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1046, N'INDIA_CITIES_TOWN_STATE', N'Ottappalam', N'Kerala', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1047, N'INDIA_CITIES_TOWN_STATE', N'Dumraon', N'Bihar', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1048, N'INDIA_CITIES_TOWN_STATE', N'Samalkot', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1049, N'INDIA_CITIES_TOWN_STATE', N'Jaggaiahpet', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1050, N'INDIA_CITIES_TOWN_STATE', N'Goalpara', N'Assam', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1051, N'INDIA_CITIES_TOWN_STATE', N'Tuni', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1052, N'INDIA_CITIES_TOWN_STATE', N'Lachhmangarh', N'Rajasthan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1053, N'INDIA_CITIES_TOWN_STATE', N'Bhongir', N'Telangana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1054, N'INDIA_CITIES_TOWN_STATE', N'Amalapuram', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1055, N'INDIA_CITIES_TOWN_STATE', N'Firozpur Cantt.', N'Punjab', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1056, N'INDIA_CITIES_TOWN_STATE', N'Vikarabad', N'Telangana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1057, N'INDIA_CITIES_TOWN_STATE', N'Thiruvalla', N'Kerala', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1058, N'INDIA_CITIES_TOWN_STATE', N'Sherkot', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1059, N'INDIA_CITIES_TOWN_STATE', N'Palghar', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1060, N'INDIA_CITIES_TOWN_STATE', N'Shegaon', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1061, N'INDIA_CITIES_TOWN_STATE', N'Jangaon', N'Telangana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1062, N'INDIA_CITIES_TOWN_STATE', N'Bheemunipatnam', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1063, N'INDIA_CITIES_TOWN_STATE', N'Panna', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1064, N'INDIA_CITIES_TOWN_STATE', N'Thodupuzha', N'Kerala', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1065, N'INDIA_CITIES_TOWN_STATE', N'KathUrban Agglomeration', N'Jammu and Kashmir', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1066, N'INDIA_CITIES_TOWN_STATE', N'Palitana', N'Gujarat', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1067, N'INDIA_CITIES_TOWN_STATE', N'Arwal', N'Bihar', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1068, N'INDIA_CITIES_TOWN_STATE', N'Venkatagiri', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1069, N'INDIA_CITIES_TOWN_STATE', N'Kalpi', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1070, N'INDIA_CITIES_TOWN_STATE', N'Rajgarh (Churu)', N'Rajasthan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1071, N'INDIA_CITIES_TOWN_STATE', N'Sattenapalle', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1072, N'INDIA_CITIES_TOWN_STATE', N'Arsikere', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1073, N'INDIA_CITIES_TOWN_STATE', N'Ozar', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1074, N'INDIA_CITIES_TOWN_STATE', N'Thirumangalam', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1075, N'INDIA_CITIES_TOWN_STATE', N'Petlad', N'Gujarat', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1076, N'INDIA_CITIES_TOWN_STATE', N'Nasirabad', N'Rajasthan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1077, N'INDIA_CITIES_TOWN_STATE', N'Phaltan', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1078, N'INDIA_CITIES_TOWN_STATE', N'Rampurhat', N'West Bengal', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1079, N'INDIA_CITIES_TOWN_STATE', N'Nanjangud', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1080, N'INDIA_CITIES_TOWN_STATE', N'Forbesganj', N'Bihar', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1081, N'INDIA_CITIES_TOWN_STATE', N'Tundla', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1082, N'INDIA_CITIES_TOWN_STATE', N'BhabUrban Agglomeration', N'Bihar', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1083, N'INDIA_CITIES_TOWN_STATE', N'Sagara', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1084, N'INDIA_CITIES_TOWN_STATE', N'Pithapuram', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1085, N'INDIA_CITIES_TOWN_STATE', N'Sira', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1086, N'INDIA_CITIES_TOWN_STATE', N'Bhadrachalam', N'Telangana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1087, N'INDIA_CITIES_TOWN_STATE', N'Charkhi Dadri', N'Haryana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1088, N'INDIA_CITIES_TOWN_STATE', N'Chatra', N'Jharkhand', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1089, N'INDIA_CITIES_TOWN_STATE', N'Palasa Kasibugga', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1090, N'INDIA_CITIES_TOWN_STATE', N'Nohar', N'Rajasthan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1091, N'INDIA_CITIES_TOWN_STATE', N'Yevla', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1092, N'INDIA_CITIES_TOWN_STATE', N'Sirhind Fatehgarh Sahib', N'Punjab', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1093, N'INDIA_CITIES_TOWN_STATE', N'Bhainsa', N'Telangana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1094, N'INDIA_CITIES_TOWN_STATE', N'Parvathipuram', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1095, N'INDIA_CITIES_TOWN_STATE', N'Shahade', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1096, N'INDIA_CITIES_TOWN_STATE', N'Chalakudy', N'Kerala', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1097, N'INDIA_CITIES_TOWN_STATE', N'Narkatiaganj', N'Bihar', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1098, N'INDIA_CITIES_TOWN_STATE', N'Kapadvanj', N'Gujarat', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1099, N'INDIA_CITIES_TOWN_STATE', N'Macherla', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1100, N'INDIA_CITIES_TOWN_STATE', N'Raghogarh-Vijaypur', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1101, N'INDIA_CITIES_TOWN_STATE', N'Rupnagar', N'Punjab', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1102, N'INDIA_CITIES_TOWN_STATE', N'Naugachhia', N'Bihar', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1103, N'INDIA_CITIES_TOWN_STATE', N'Sendhwa', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1104, N'INDIA_CITIES_TOWN_STATE', N'Byasanagar', N'Odisha', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1105, N'INDIA_CITIES_TOWN_STATE', N'Sandila', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1106, N'INDIA_CITIES_TOWN_STATE', N'Gooty', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1107, N'INDIA_CITIES_TOWN_STATE', N'Salur', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1108, N'INDIA_CITIES_TOWN_STATE', N'Nanpara', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1109, N'INDIA_CITIES_TOWN_STATE', N'Sardhana', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1110, N'INDIA_CITIES_TOWN_STATE', N'Vita', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1111, N'INDIA_CITIES_TOWN_STATE', N'Gumia', N'Jharkhand', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1112, N'INDIA_CITIES_TOWN_STATE', N'Puttur', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1113, N'INDIA_CITIES_TOWN_STATE', N'Jalandhar Cantt.', N'Punjab', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1114, N'INDIA_CITIES_TOWN_STATE', N'Nehtaur', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1115, N'INDIA_CITIES_TOWN_STATE', N'Changanassery', N'Kerala', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1116, N'INDIA_CITIES_TOWN_STATE', N'Mandapeta', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1117, N'INDIA_CITIES_TOWN_STATE', N'Dumka', N'Jharkhand', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1118, N'INDIA_CITIES_TOWN_STATE', N'Seohara', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1119, N'INDIA_CITIES_TOWN_STATE', N'Umarkhed', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1120, N'INDIA_CITIES_TOWN_STATE', N'Madhupur', N'Jharkhand', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1121, N'INDIA_CITIES_TOWN_STATE', N'Vikramasingapuram', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1122, N'INDIA_CITIES_TOWN_STATE', N'Punalur', N'Kerala', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1123, N'INDIA_CITIES_TOWN_STATE', N'Kendrapara', N'Odisha', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1124, N'INDIA_CITIES_TOWN_STATE', N'Sihor', N'Gujarat', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1125, N'INDIA_CITIES_TOWN_STATE', N'Nellikuppam', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1126, N'INDIA_CITIES_TOWN_STATE', N'Samana', N'Punjab', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1127, N'INDIA_CITIES_TOWN_STATE', N'Warora', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1128, N'INDIA_CITIES_TOWN_STATE', N'Nilambur', N'Kerala', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1129, N'INDIA_CITIES_TOWN_STATE', N'Rasipuram', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1130, N'INDIA_CITIES_TOWN_STATE', N'Ramnagar', N'Uttarakhand', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1131, N'INDIA_CITIES_TOWN_STATE', N'Jammalamadugu', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1132, N'INDIA_CITIES_TOWN_STATE', N'Nawanshahr', N'Punjab', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1133, N'INDIA_CITIES_TOWN_STATE', N'Thoubal', N'Manipur', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1134, N'INDIA_CITIES_TOWN_STATE', N'Athni', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1135, N'INDIA_CITIES_TOWN_STATE', N'Cherthala', N'Kerala', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1136, N'INDIA_CITIES_TOWN_STATE', N'Sidhi', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1137, N'INDIA_CITIES_TOWN_STATE', N'Farooqnagar', N'Telangana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1138, N'INDIA_CITIES_TOWN_STATE', N'Peddapuram', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1139, N'INDIA_CITIES_TOWN_STATE', N'Chirkunda', N'Jharkhand', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1140, N'INDIA_CITIES_TOWN_STATE', N'Pachora', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1141, N'INDIA_CITIES_TOWN_STATE', N'Madhepura', N'Bihar', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1142, N'INDIA_CITIES_TOWN_STATE', N'Pithoragarh', N'Uttarakhand', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1143, N'INDIA_CITIES_TOWN_STATE', N'Tumsar', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1144, N'INDIA_CITIES_TOWN_STATE', N'Phalodi', N'Rajasthan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1145, N'INDIA_CITIES_TOWN_STATE', N'Tiruttani', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1146, N'INDIA_CITIES_TOWN_STATE', N'Rampura Phul', N'Punjab', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1147, N'INDIA_CITIES_TOWN_STATE', N'Perinthalmanna', N'Kerala', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1148, N'INDIA_CITIES_TOWN_STATE', N'Padrauna', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1149, N'INDIA_CITIES_TOWN_STATE', N'Pipariya', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1150, N'INDIA_CITIES_TOWN_STATE', N'Dalli-Rajhara', N'Chhattisgarh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1151, N'INDIA_CITIES_TOWN_STATE', N'Punganur', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1152, N'INDIA_CITIES_TOWN_STATE', N'Mattannur', N'Kerala', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1153, N'INDIA_CITIES_TOWN_STATE', N'Mathura', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1154, N'INDIA_CITIES_TOWN_STATE', N'Thakurdwara', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1155, N'INDIA_CITIES_TOWN_STATE', N'Nandivaram-Guduvancheri', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1156, N'INDIA_CITIES_TOWN_STATE', N'Mulbagal', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1157, N'INDIA_CITIES_TOWN_STATE', N'Manjlegaon', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1158, N'INDIA_CITIES_TOWN_STATE', N'Wankaner', N'Gujarat', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1159, N'INDIA_CITIES_TOWN_STATE', N'Sillod', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1160, N'INDIA_CITIES_TOWN_STATE', N'Nidadavole', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1161, N'INDIA_CITIES_TOWN_STATE', N'Surapura', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1162, N'INDIA_CITIES_TOWN_STATE', N'Rajagangapur', N'Odisha', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1163, N'INDIA_CITIES_TOWN_STATE', N'Sheikhpura', N'Bihar', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1164, N'INDIA_CITIES_TOWN_STATE', N'Parlakhemundi', N'Odisha', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1165, N'INDIA_CITIES_TOWN_STATE', N'Kalimpong', N'West Bengal', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1166, N'INDIA_CITIES_TOWN_STATE', N'Siruguppa', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1167, N'INDIA_CITIES_TOWN_STATE', N'Arvi', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1168, N'INDIA_CITIES_TOWN_STATE', N'Limbdi', N'Gujarat', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1169, N'INDIA_CITIES_TOWN_STATE', N'Barpeta', N'Assam', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1170, N'INDIA_CITIES_TOWN_STATE', N'Manglaur', N'Uttarakhand', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1171, N'INDIA_CITIES_TOWN_STATE', N'Repalle', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1172, N'INDIA_CITIES_TOWN_STATE', N'Mudhol', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1173, N'INDIA_CITIES_TOWN_STATE', N'Shujalpur', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1174, N'INDIA_CITIES_TOWN_STATE', N'Mandvi', N'Gujarat', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1175, N'INDIA_CITIES_TOWN_STATE', N'Thangadh', N'Gujarat', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1176, N'INDIA_CITIES_TOWN_STATE', N'Sironj', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1177, N'INDIA_CITIES_TOWN_STATE', N'Nandura', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1178, N'INDIA_CITIES_TOWN_STATE', N'Shoranur', N'Kerala', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1179, N'INDIA_CITIES_TOWN_STATE', N'Nathdwara', N'Rajasthan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1180, N'INDIA_CITIES_TOWN_STATE', N'Periyakulam', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1181, N'INDIA_CITIES_TOWN_STATE', N'Sultanganj', N'Bihar', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1182, N'INDIA_CITIES_TOWN_STATE', N'Medak', N'Telangana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1183, N'INDIA_CITIES_TOWN_STATE', N'Narayanpet', N'Telangana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1184, N'INDIA_CITIES_TOWN_STATE', N'Raxaul Bazar', N'Bihar', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1185, N'INDIA_CITIES_TOWN_STATE', N'Rajauri', N'Jammu and Kashmir', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1186, N'INDIA_CITIES_TOWN_STATE', N'Pernampattu', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1187, N'INDIA_CITIES_TOWN_STATE', N'Nainital', N'Uttarakhand', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1188, N'INDIA_CITIES_TOWN_STATE', N'Ramachandrapuram', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1189, N'INDIA_CITIES_TOWN_STATE', N'Vaijapur', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1190, N'INDIA_CITIES_TOWN_STATE', N'Nangal', N'Punjab', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1191, N'INDIA_CITIES_TOWN_STATE', N'Sidlaghatta', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1192, N'INDIA_CITIES_TOWN_STATE', N'Punch', N'Jammu and Kashmir', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1193, N'INDIA_CITIES_TOWN_STATE', N'Pandhurna', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1194, N'INDIA_CITIES_TOWN_STATE', N'Wadgaon Road', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1195, N'INDIA_CITIES_TOWN_STATE', N'Talcher', N'Odisha', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1196, N'INDIA_CITIES_TOWN_STATE', N'Varkala', N'Kerala', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1197, N'INDIA_CITIES_TOWN_STATE', N'Pilani', N'Rajasthan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1198, N'INDIA_CITIES_TOWN_STATE', N'Nowgong', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1199, N'INDIA_CITIES_TOWN_STATE', N'Naila Janjgir', N'Chhattisgarh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1200, N'INDIA_CITIES_TOWN_STATE', N'Mapusa', N'Goa', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1201, N'INDIA_CITIES_TOWN_STATE', N'Vellakoil', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1202, N'INDIA_CITIES_TOWN_STATE', N'Merta City', N'Rajasthan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1203, N'INDIA_CITIES_TOWN_STATE', N'Sivaganga', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1204, N'INDIA_CITIES_TOWN_STATE', N'Mandideep', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1205, N'INDIA_CITIES_TOWN_STATE', N'Sailu', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1206, N'INDIA_CITIES_TOWN_STATE', N'Vyara', N'Gujarat', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1207, N'INDIA_CITIES_TOWN_STATE', N'Kovvur', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1208, N'INDIA_CITIES_TOWN_STATE', N'Vadalur', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1209, N'INDIA_CITIES_TOWN_STATE', N'Nawabganj', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1210, N'INDIA_CITIES_TOWN_STATE', N'Padra', N'Gujarat', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1211, N'INDIA_CITIES_TOWN_STATE', N'Sainthia', N'West Bengal', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1212, N'INDIA_CITIES_TOWN_STATE', N'Siana', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1213, N'INDIA_CITIES_TOWN_STATE', N'Shahpur', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1214, N'INDIA_CITIES_TOWN_STATE', N'Sojat', N'Rajasthan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1215, N'INDIA_CITIES_TOWN_STATE', N'Noorpur', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1216, N'INDIA_CITIES_TOWN_STATE', N'Paravoor', N'Kerala', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1217, N'INDIA_CITIES_TOWN_STATE', N'Murtijapur', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1218, N'INDIA_CITIES_TOWN_STATE', N'Ramnagar', N'Bihar', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1219, N'INDIA_CITIES_TOWN_STATE', N'Sundargarh', N'Odisha', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1220, N'INDIA_CITIES_TOWN_STATE', N'Taki', N'West Bengal', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1221, N'INDIA_CITIES_TOWN_STATE', N'Saundatti-Yellamma', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1222, N'INDIA_CITIES_TOWN_STATE', N'Pathanamthitta', N'Kerala', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1223, N'INDIA_CITIES_TOWN_STATE', N'Wadi', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1224, N'INDIA_CITIES_TOWN_STATE', N'Rameshwaram', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1225, N'INDIA_CITIES_TOWN_STATE', N'Tasgaon', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1226, N'INDIA_CITIES_TOWN_STATE', N'Sikandra Rao', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1227, N'INDIA_CITIES_TOWN_STATE', N'Sihora', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1228, N'INDIA_CITIES_TOWN_STATE', N'Tiruvethipuram', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1229, N'INDIA_CITIES_TOWN_STATE', N'Tiruvuru', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1230, N'INDIA_CITIES_TOWN_STATE', N'Mehkar', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1231, N'INDIA_CITIES_TOWN_STATE', N'Peringathur', N'Kerala', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1232, N'INDIA_CITIES_TOWN_STATE', N'Perambalur', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1233, N'INDIA_CITIES_TOWN_STATE', N'Manvi', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1234, N'INDIA_CITIES_TOWN_STATE', N'Zunheboto', N'Nagaland', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1235, N'INDIA_CITIES_TOWN_STATE', N'Mahnar Bazar', N'Bihar', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1236, N'INDIA_CITIES_TOWN_STATE', N'Attingal', N'Kerala', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1237, N'INDIA_CITIES_TOWN_STATE', N'Shahbad', N'Haryana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1238, N'INDIA_CITIES_TOWN_STATE', N'Puranpur', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1239, N'INDIA_CITIES_TOWN_STATE', N'Nelamangala', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1240, N'INDIA_CITIES_TOWN_STATE', N'Nakodar', N'Punjab', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1241, N'INDIA_CITIES_TOWN_STATE', N'Lunawada', N'Gujarat', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1242, N'INDIA_CITIES_TOWN_STATE', N'Murshidabad', N'West Bengal', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1243, N'INDIA_CITIES_TOWN_STATE', N'Mahe', N'Puducherry', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1244, N'INDIA_CITIES_TOWN_STATE', N'Lanka', N'Assam', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1245, N'INDIA_CITIES_TOWN_STATE', N'Rudauli', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1246, N'INDIA_CITIES_TOWN_STATE', N'Tuensang', N'Nagaland', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1247, N'INDIA_CITIES_TOWN_STATE', N'Lakshmeshwar', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1248, N'INDIA_CITIES_TOWN_STATE', N'Zira', N'Punjab', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1249, N'INDIA_CITIES_TOWN_STATE', N'Yawal', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1250, N'INDIA_CITIES_TOWN_STATE', N'Thana Bhawan', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1251, N'INDIA_CITIES_TOWN_STATE', N'Ramdurg', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1252, N'INDIA_CITIES_TOWN_STATE', N'Pulgaon', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1253, N'INDIA_CITIES_TOWN_STATE', N'Sadasivpet', N'Telangana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1254, N'INDIA_CITIES_TOWN_STATE', N'Nargund', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1255, N'INDIA_CITIES_TOWN_STATE', N'Neem-Ka-Thana', N'Rajasthan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1256, N'INDIA_CITIES_TOWN_STATE', N'Memari', N'West Bengal', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1257, N'INDIA_CITIES_TOWN_STATE', N'Nilanga', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1258, N'INDIA_CITIES_TOWN_STATE', N'Naharlagun', N'Arunachal Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1259, N'INDIA_CITIES_TOWN_STATE', N'Pakaur', N'Jharkhand', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1260, N'INDIA_CITIES_TOWN_STATE', N'Wai', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1261, N'INDIA_CITIES_TOWN_STATE', N'Tarikere', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1262, N'INDIA_CITIES_TOWN_STATE', N'Malavalli', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1263, N'INDIA_CITIES_TOWN_STATE', N'Raisen', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1264, N'INDIA_CITIES_TOWN_STATE', N'Lahar', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1265, N'INDIA_CITIES_TOWN_STATE', N'Uravakonda', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1266, N'INDIA_CITIES_TOWN_STATE', N'Savanur', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1267, N'INDIA_CITIES_TOWN_STATE', N'Sirohi', N'Rajasthan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1268, N'INDIA_CITIES_TOWN_STATE', N'Udhampur', N'Jammu and Kashmir', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1269, N'INDIA_CITIES_TOWN_STATE', N'Umarga', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1270, N'INDIA_CITIES_TOWN_STATE', N'Pratapgarh', N'Rajasthan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1271, N'INDIA_CITIES_TOWN_STATE', N'Lingsugur', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1272, N'INDIA_CITIES_TOWN_STATE', N'Usilampatti', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1273, N'INDIA_CITIES_TOWN_STATE', N'Palia Kalan', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1274, N'INDIA_CITIES_TOWN_STATE', N'Wokha', N'Nagaland', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1275, N'INDIA_CITIES_TOWN_STATE', N'Rajpipla', N'Gujarat', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1276, N'INDIA_CITIES_TOWN_STATE', N'Vijayapura', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1277, N'INDIA_CITIES_TOWN_STATE', N'Rawatbhata', N'Rajasthan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1278, N'INDIA_CITIES_TOWN_STATE', N'Sangaria', N'Rajasthan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1279, N'INDIA_CITIES_TOWN_STATE', N'Paithan', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1280, N'INDIA_CITIES_TOWN_STATE', N'Rahuri', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1281, N'INDIA_CITIES_TOWN_STATE', N'Patti', N'Punjab', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1282, N'INDIA_CITIES_TOWN_STATE', N'Zaidpur', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1283, N'INDIA_CITIES_TOWN_STATE', N'Lalsot', N'Rajasthan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1284, N'INDIA_CITIES_TOWN_STATE', N'Maihar', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1285, N'INDIA_CITIES_TOWN_STATE', N'Vedaranyam', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1286, N'INDIA_CITIES_TOWN_STATE', N'Nawapur', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1287, N'INDIA_CITIES_TOWN_STATE', N'Solan', N'Himachal Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1288, N'INDIA_CITIES_TOWN_STATE', N'Vapi', N'Gujarat', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1289, N'INDIA_CITIES_TOWN_STATE', N'Sanawad', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1290, N'INDIA_CITIES_TOWN_STATE', N'Warisaliganj', N'Bihar', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1291, N'INDIA_CITIES_TOWN_STATE', N'Revelganj', N'Bihar', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1292, N'INDIA_CITIES_TOWN_STATE', N'Sabalgarh', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1293, N'INDIA_CITIES_TOWN_STATE', N'Tuljapur', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1294, N'INDIA_CITIES_TOWN_STATE', N'Simdega', N'Jharkhand', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1295, N'INDIA_CITIES_TOWN_STATE', N'Musabani', N'Jharkhand', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1296, N'INDIA_CITIES_TOWN_STATE', N'Kodungallur', N'Kerala', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1297, N'INDIA_CITIES_TOWN_STATE', N'Phulabani', N'Odisha', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1298, N'INDIA_CITIES_TOWN_STATE', N'Umreth', N'Gujarat', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1299, N'INDIA_CITIES_TOWN_STATE', N'Narsipatnam', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1300, N'INDIA_CITIES_TOWN_STATE', N'Nautanwa', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1301, N'INDIA_CITIES_TOWN_STATE', N'Rajgir', N'Bihar', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1302, N'INDIA_CITIES_TOWN_STATE', N'Yellandu', N'Telangana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1303, N'INDIA_CITIES_TOWN_STATE', N'Sathyamangalam', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1304, N'INDIA_CITIES_TOWN_STATE', N'Pilibanga', N'Rajasthan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1305, N'INDIA_CITIES_TOWN_STATE', N'Morshi', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1306, N'INDIA_CITIES_TOWN_STATE', N'Pehowa', N'Haryana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1307, N'INDIA_CITIES_TOWN_STATE', N'Sonepur', N'Bihar', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1308, N'INDIA_CITIES_TOWN_STATE', N'Pappinisseri', N'Kerala', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1309, N'INDIA_CITIES_TOWN_STATE', N'Zamania', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1310, N'INDIA_CITIES_TOWN_STATE', N'Mihijam', N'Jharkhand', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1311, N'INDIA_CITIES_TOWN_STATE', N'Purna', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1312, N'INDIA_CITIES_TOWN_STATE', N'Puliyankudi', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1313, N'INDIA_CITIES_TOWN_STATE', N'Shikarpur, Bulandshahr', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1314, N'INDIA_CITIES_TOWN_STATE', N'Umaria', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1315, N'INDIA_CITIES_TOWN_STATE', N'Porsa', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1316, N'INDIA_CITIES_TOWN_STATE', N'Naugawan Sadat', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1317, N'INDIA_CITIES_TOWN_STATE', N'Fatehpur Sikri', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1318, N'INDIA_CITIES_TOWN_STATE', N'Manuguru', N'Telangana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1319, N'INDIA_CITIES_TOWN_STATE', N'Udaipur', N'Tripura', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1320, N'INDIA_CITIES_TOWN_STATE', N'Pipar City', N'Rajasthan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1321, N'INDIA_CITIES_TOWN_STATE', N'Pattamundai', N'Odisha', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1322, N'INDIA_CITIES_TOWN_STATE', N'Nanjikottai', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1323, N'INDIA_CITIES_TOWN_STATE', N'Taranagar', N'Rajasthan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1324, N'INDIA_CITIES_TOWN_STATE', N'Yerraguntla', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1325, N'INDIA_CITIES_TOWN_STATE', N'Satana', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1326, N'INDIA_CITIES_TOWN_STATE', N'Sherghati', N'Bihar', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1327, N'INDIA_CITIES_TOWN_STATE', N'Sankeshwara', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1328, N'INDIA_CITIES_TOWN_STATE', N'Madikeri', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1329, N'INDIA_CITIES_TOWN_STATE', N'Thuraiyur', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1330, N'INDIA_CITIES_TOWN_STATE', N'Sanand', N'Gujarat', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1331, N'INDIA_CITIES_TOWN_STATE', N'Rajula', N'Gujarat', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1332, N'INDIA_CITIES_TOWN_STATE', N'Kyathampalle', N'Telangana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1333, N'INDIA_CITIES_TOWN_STATE', N'Shahabad, Rampur', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1334, N'INDIA_CITIES_TOWN_STATE', N'Tilda Newra', N'Chhattisgarh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1335, N'INDIA_CITIES_TOWN_STATE', N'Narsinghgarh', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1336, N'INDIA_CITIES_TOWN_STATE', N'Chittur-Thathamangalam', N'Kerala', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1337, N'INDIA_CITIES_TOWN_STATE', N'Malaj Khand', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1338, N'INDIA_CITIES_TOWN_STATE', N'Sarangpur', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1339, N'INDIA_CITIES_TOWN_STATE', N'Robertsganj', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1340, N'INDIA_CITIES_TOWN_STATE', N'Sirkali', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1341, N'INDIA_CITIES_TOWN_STATE', N'Radhanpur', N'Gujarat', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1342, N'INDIA_CITIES_TOWN_STATE', N'Tiruchendur', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1343, N'INDIA_CITIES_TOWN_STATE', N'Utraula', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1344, N'INDIA_CITIES_TOWN_STATE', N'Patratu', N'Jharkhand', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1345, N'INDIA_CITIES_TOWN_STATE', N'Vijainagar, Ajmer', N'Rajasthan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1346, N'INDIA_CITIES_TOWN_STATE', N'Periyasemur', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1347, N'INDIA_CITIES_TOWN_STATE', N'Pathri', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1348, N'INDIA_CITIES_TOWN_STATE', N'Sadabad', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1349, N'INDIA_CITIES_TOWN_STATE', N'Talikota', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1350, N'INDIA_CITIES_TOWN_STATE', N'Sinnar', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1351, N'INDIA_CITIES_TOWN_STATE', N'Mungeli', N'Chhattisgarh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1352, N'INDIA_CITIES_TOWN_STATE', N'Sedam', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1353, N'INDIA_CITIES_TOWN_STATE', N'Shikaripur', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1354, N'INDIA_CITIES_TOWN_STATE', N'Sumerpur', N'Rajasthan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1355, N'INDIA_CITIES_TOWN_STATE', N'Sattur', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1356, N'INDIA_CITIES_TOWN_STATE', N'Sugauli', N'Bihar', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1357, N'INDIA_CITIES_TOWN_STATE', N'Lumding', N'Assam', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1358, N'INDIA_CITIES_TOWN_STATE', N'Vandavasi', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1359, N'INDIA_CITIES_TOWN_STATE', N'Titlagarh', N'Odisha', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1360, N'INDIA_CITIES_TOWN_STATE', N'Uchgaon', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1361, N'INDIA_CITIES_TOWN_STATE', N'Mokokchung', N'Nagaland', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1362, N'INDIA_CITIES_TOWN_STATE', N'Paschim Punropara', N'West Bengal', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1363, N'INDIA_CITIES_TOWN_STATE', N'Sagwara', N'Rajasthan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1364, N'INDIA_CITIES_TOWN_STATE', N'Ramganj Mandi', N'Rajasthan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1365, N'INDIA_CITIES_TOWN_STATE', N'Tarakeswar', N'West Bengal', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1366, N'INDIA_CITIES_TOWN_STATE', N'Mahalingapura', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1367, N'INDIA_CITIES_TOWN_STATE', N'Dharmanagar', N'Tripura', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1368, N'INDIA_CITIES_TOWN_STATE', N'Mahemdabad', N'Gujarat', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1369, N'INDIA_CITIES_TOWN_STATE', N'Manendragarh', N'Chhattisgarh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1370, N'INDIA_CITIES_TOWN_STATE', N'Uran', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1371, N'INDIA_CITIES_TOWN_STATE', N'Tharamangalam', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1372, N'INDIA_CITIES_TOWN_STATE', N'Tirukkoyilur', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1373, N'INDIA_CITIES_TOWN_STATE', N'Pen', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1374, N'INDIA_CITIES_TOWN_STATE', N'Makhdumpur', N'Bihar', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1375, N'INDIA_CITIES_TOWN_STATE', N'Maner', N'Bihar', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1376, N'INDIA_CITIES_TOWN_STATE', N'Oddanchatram', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1377, N'INDIA_CITIES_TOWN_STATE', N'Palladam', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1378, N'INDIA_CITIES_TOWN_STATE', N'Mundi', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1379, N'INDIA_CITIES_TOWN_STATE', N'Nabarangapur', N'Odisha', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1380, N'INDIA_CITIES_TOWN_STATE', N'Mudalagi', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1381, N'INDIA_CITIES_TOWN_STATE', N'Samalkha', N'Haryana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1382, N'INDIA_CITIES_TOWN_STATE', N'Nepanagar', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1383, N'INDIA_CITIES_TOWN_STATE', N'Karjat', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1384, N'INDIA_CITIES_TOWN_STATE', N'Ranavav', N'Gujarat', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1385, N'INDIA_CITIES_TOWN_STATE', N'Pedana', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1386, N'INDIA_CITIES_TOWN_STATE', N'Pinjore', N'Haryana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1387, N'INDIA_CITIES_TOWN_STATE', N'Lakheri', N'Rajasthan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1388, N'INDIA_CITIES_TOWN_STATE', N'Pasan', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1389, N'INDIA_CITIES_TOWN_STATE', N'Puttur', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1390, N'INDIA_CITIES_TOWN_STATE', N'Vadakkuvalliyur', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1391, N'INDIA_CITIES_TOWN_STATE', N'Tirukalukundram', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1392, N'INDIA_CITIES_TOWN_STATE', N'Mahidpur', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1393, N'INDIA_CITIES_TOWN_STATE', N'Mussoorie', N'Uttarakhand', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1394, N'INDIA_CITIES_TOWN_STATE', N'Muvattupuzha', N'Kerala', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1395, N'INDIA_CITIES_TOWN_STATE', N'Rasra', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1396, N'INDIA_CITIES_TOWN_STATE', N'Udaipurwati', N'Rajasthan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1397, N'INDIA_CITIES_TOWN_STATE', N'Manwath', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1398, N'INDIA_CITIES_TOWN_STATE', N'Adoor', N'Kerala', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1399, N'INDIA_CITIES_TOWN_STATE', N'Uthamapalayam', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1400, N'INDIA_CITIES_TOWN_STATE', N'Partur', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1401, N'INDIA_CITIES_TOWN_STATE', N'Nahan', N'Himachal Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1402, N'INDIA_CITIES_TOWN_STATE', N'Ladwa', N'Haryana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1403, N'INDIA_CITIES_TOWN_STATE', N'Mankachar', N'Assam', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1404, N'INDIA_CITIES_TOWN_STATE', N'Nongstoin', N'Meghalaya', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1405, N'INDIA_CITIES_TOWN_STATE', N'Losal', N'Rajasthan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1406, N'INDIA_CITIES_TOWN_STATE', N'Sri Madhopur', N'Rajasthan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1407, N'INDIA_CITIES_TOWN_STATE', N'Ramngarh', N'Rajasthan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1408, N'INDIA_CITIES_TOWN_STATE', N'Mavelikkara', N'Kerala', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1409, N'INDIA_CITIES_TOWN_STATE', N'Rawatsar', N'Rajasthan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1410, N'INDIA_CITIES_TOWN_STATE', N'Rajakhera', N'Rajasthan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1411, N'INDIA_CITIES_TOWN_STATE', N'Lar', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1412, N'INDIA_CITIES_TOWN_STATE', N'Lal Gopalganj Nindaura', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1413, N'INDIA_CITIES_TOWN_STATE', N'Muddebihal', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1414, N'INDIA_CITIES_TOWN_STATE', N'Sirsaganj', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1415, N'INDIA_CITIES_TOWN_STATE', N'Shahpura', N'Rajasthan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1416, N'INDIA_CITIES_TOWN_STATE', N'Surandai', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1417, N'INDIA_CITIES_TOWN_STATE', N'Sangole', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1418, N'INDIA_CITIES_TOWN_STATE', N'Pavagada', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1419, N'INDIA_CITIES_TOWN_STATE', N'Tharad', N'Gujarat', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1420, N'INDIA_CITIES_TOWN_STATE', N'Mansa', N'Gujarat', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1421, N'INDIA_CITIES_TOWN_STATE', N'Umbergaon', N'Gujarat', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1422, N'INDIA_CITIES_TOWN_STATE', N'Mavoor', N'Kerala', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1423, N'INDIA_CITIES_TOWN_STATE', N'Nalbari', N'Assam', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1424, N'INDIA_CITIES_TOWN_STATE', N'Talaja', N'Gujarat', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1425, N'INDIA_CITIES_TOWN_STATE', N'Malur', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1426, N'INDIA_CITIES_TOWN_STATE', N'Mangrulpir', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1427, N'INDIA_CITIES_TOWN_STATE', N'Soro', N'Odisha', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1428, N'INDIA_CITIES_TOWN_STATE', N'Shahpura', N'Rajasthan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1429, N'INDIA_CITIES_TOWN_STATE', N'Vadnagar', N'Gujarat', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1430, N'INDIA_CITIES_TOWN_STATE', N'Raisinghnagar', N'Rajasthan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1431, N'INDIA_CITIES_TOWN_STATE', N'Sindhagi', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1432, N'INDIA_CITIES_TOWN_STATE', N'Sanduru', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1433, N'INDIA_CITIES_TOWN_STATE', N'Sohna', N'Haryana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1434, N'INDIA_CITIES_TOWN_STATE', N'Manavadar', N'Gujarat', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1435, N'INDIA_CITIES_TOWN_STATE', N'Pihani', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1436, N'INDIA_CITIES_TOWN_STATE', N'Safidon', N'Haryana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1437, N'INDIA_CITIES_TOWN_STATE', N'Risod', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1438, N'INDIA_CITIES_TOWN_STATE', N'Rosera', N'Bihar', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1439, N'INDIA_CITIES_TOWN_STATE', N'Sankari', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1440, N'INDIA_CITIES_TOWN_STATE', N'Malpura', N'Rajasthan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1441, N'INDIA_CITIES_TOWN_STATE', N'Sonamukhi', N'West Bengal', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1442, N'INDIA_CITIES_TOWN_STATE', N'Shamsabad, Agra', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1443, N'INDIA_CITIES_TOWN_STATE', N'Nokha', N'Bihar', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1444, N'INDIA_CITIES_TOWN_STATE', N'PandUrban Agglomeration', N'West Bengal', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1445, N'INDIA_CITIES_TOWN_STATE', N'Mainaguri', N'West Bengal', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1446, N'INDIA_CITIES_TOWN_STATE', N'Afzalpur', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1447, N'INDIA_CITIES_TOWN_STATE', N'Shirur', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1448, N'INDIA_CITIES_TOWN_STATE', N'Salaya', N'Gujarat', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1449, N'INDIA_CITIES_TOWN_STATE', N'Shenkottai', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1450, N'INDIA_CITIES_TOWN_STATE', N'Pratapgarh', N'Tripura', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1451, N'INDIA_CITIES_TOWN_STATE', N'Vadipatti', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1452, N'INDIA_CITIES_TOWN_STATE', N'Nagarkurnool', N'Telangana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1453, N'INDIA_CITIES_TOWN_STATE', N'Savner', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1454, N'INDIA_CITIES_TOWN_STATE', N'Sasvad', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1455, N'INDIA_CITIES_TOWN_STATE', N'Rudrapur', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1456, N'INDIA_CITIES_TOWN_STATE', N'Soron', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1457, N'INDIA_CITIES_TOWN_STATE', N'Sholingur', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1458, N'INDIA_CITIES_TOWN_STATE', N'Pandharkaoda', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1459, N'INDIA_CITIES_TOWN_STATE', N'Perumbavoor', N'Kerala', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1460, N'INDIA_CITIES_TOWN_STATE', N'Maddur', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1461, N'INDIA_CITIES_TOWN_STATE', N'Nadbai', N'Rajasthan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1462, N'INDIA_CITIES_TOWN_STATE', N'Talode', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1463, N'INDIA_CITIES_TOWN_STATE', N'Shrigonda', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1464, N'INDIA_CITIES_TOWN_STATE', N'Madhugiri', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1465, N'INDIA_CITIES_TOWN_STATE', N'Tekkalakote', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1466, N'INDIA_CITIES_TOWN_STATE', N'Seoni-Malwa', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1467, N'INDIA_CITIES_TOWN_STATE', N'Shirdi', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1468, N'INDIA_CITIES_TOWN_STATE', N'SUrban Agglomerationr', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1469, N'INDIA_CITIES_TOWN_STATE', N'Terdal', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1470, N'INDIA_CITIES_TOWN_STATE', N'Raver', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1471, N'INDIA_CITIES_TOWN_STATE', N'Tirupathur', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1472, N'INDIA_CITIES_TOWN_STATE', N'Taraori', N'Haryana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1473, N'INDIA_CITIES_TOWN_STATE', N'Mukhed', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1474, N'INDIA_CITIES_TOWN_STATE', N'Manachanallur', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1475, N'INDIA_CITIES_TOWN_STATE', N'Rehli', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1476, N'INDIA_CITIES_TOWN_STATE', N'Sanchore', N'Rajasthan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1477, N'INDIA_CITIES_TOWN_STATE', N'Rajura', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1478, N'INDIA_CITIES_TOWN_STATE', N'Piro', N'Bihar', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1479, N'INDIA_CITIES_TOWN_STATE', N'Mudabidri', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1480, N'INDIA_CITIES_TOWN_STATE', N'Vadgaon Kasba', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1481, N'INDIA_CITIES_TOWN_STATE', N'Nagar', N'Rajasthan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1482, N'INDIA_CITIES_TOWN_STATE', N'Vijapur', N'Gujarat', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1483, N'INDIA_CITIES_TOWN_STATE', N'Viswanatham', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1484, N'INDIA_CITIES_TOWN_STATE', N'Polur', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1485, N'INDIA_CITIES_TOWN_STATE', N'Panagudi', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1486, N'INDIA_CITIES_TOWN_STATE', N'Manawar', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1487, N'INDIA_CITIES_TOWN_STATE', N'Tehri', N'Uttarakhand', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1488, N'INDIA_CITIES_TOWN_STATE', N'Samdhan', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1489, N'INDIA_CITIES_TOWN_STATE', N'Pardi', N'Gujarat', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1490, N'INDIA_CITIES_TOWN_STATE', N'Rahatgarh', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1491, N'INDIA_CITIES_TOWN_STATE', N'Panagar', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1492, N'INDIA_CITIES_TOWN_STATE', N'Uthiramerur', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1493, N'INDIA_CITIES_TOWN_STATE', N'Tirora', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1494, N'INDIA_CITIES_TOWN_STATE', N'Rangia', N'Assam', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1495, N'INDIA_CITIES_TOWN_STATE', N'Sahjanwa', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1496, N'INDIA_CITIES_TOWN_STATE', N'Wara Seoni', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1497, N'INDIA_CITIES_TOWN_STATE', N'Magadi', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1498, N'INDIA_CITIES_TOWN_STATE', N'Rajgarh (Alwar)', N'Rajasthan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1499, N'INDIA_CITIES_TOWN_STATE', N'Rafiganj', N'Bihar', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1500, N'INDIA_CITIES_TOWN_STATE', N'Tarana', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1501, N'INDIA_CITIES_TOWN_STATE', N'Rampur Maniharan', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1502, N'INDIA_CITIES_TOWN_STATE', N'Sheoganj', N'Rajasthan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1503, N'INDIA_CITIES_TOWN_STATE', N'Raikot', N'Punjab', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1504, N'INDIA_CITIES_TOWN_STATE', N'Pauri', N'Uttarakhand', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1505, N'INDIA_CITIES_TOWN_STATE', N'Sumerpur', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1506, N'INDIA_CITIES_TOWN_STATE', N'Navalgund', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1507, N'INDIA_CITIES_TOWN_STATE', N'Shahganj', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1508, N'INDIA_CITIES_TOWN_STATE', N'Marhaura', N'Bihar', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1509, N'INDIA_CITIES_TOWN_STATE', N'Tulsipur', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1510, N'INDIA_CITIES_TOWN_STATE', N'Sadri', N'Rajasthan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1511, N'INDIA_CITIES_TOWN_STATE', N'Thiruthuraipoondi', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1512, N'INDIA_CITIES_TOWN_STATE', N'Shiggaon', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1513, N'INDIA_CITIES_TOWN_STATE', N'Pallapatti', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1514, N'INDIA_CITIES_TOWN_STATE', N'Mahendragarh', N'Haryana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1515, N'INDIA_CITIES_TOWN_STATE', N'Sausar', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1516, N'INDIA_CITIES_TOWN_STATE', N'Ponneri', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1517, N'INDIA_CITIES_TOWN_STATE', N'Mahad', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1518, N'INDIA_CITIES_TOWN_STATE', N'Lohardaga', N'Jharkhand', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1519, N'INDIA_CITIES_TOWN_STATE', N'Tirwaganj', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1520, N'INDIA_CITIES_TOWN_STATE', N'Margherita', N'Assam', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1521, N'INDIA_CITIES_TOWN_STATE', N'Sundarnagar', N'Himachal Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1522, N'INDIA_CITIES_TOWN_STATE', N'Rajgarh', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1523, N'INDIA_CITIES_TOWN_STATE', N'Mangaldoi', N'Assam', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1524, N'INDIA_CITIES_TOWN_STATE', N'Renigunta', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1525, N'INDIA_CITIES_TOWN_STATE', N'Longowal', N'Punjab', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1526, N'INDIA_CITIES_TOWN_STATE', N'Ratia', N'Haryana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1527, N'INDIA_CITIES_TOWN_STATE', N'Lalgudi', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1528, N'INDIA_CITIES_TOWN_STATE', N'Shrirangapattana', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1529, N'INDIA_CITIES_TOWN_STATE', N'Niwari', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1530, N'INDIA_CITIES_TOWN_STATE', N'Natham', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1531, N'INDIA_CITIES_TOWN_STATE', N'Unnamalaikadai', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1532, N'INDIA_CITIES_TOWN_STATE', N'PurqUrban Agglomerationzi', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1533, N'INDIA_CITIES_TOWN_STATE', N'Shamsabad, Farrukhabad', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1534, N'INDIA_CITIES_TOWN_STATE', N'Mirganj', N'Bihar', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1535, N'INDIA_CITIES_TOWN_STATE', N'Todaraisingh', N'Rajasthan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1536, N'INDIA_CITIES_TOWN_STATE', N'Warhapur', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1537, N'INDIA_CITIES_TOWN_STATE', N'Rajam', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1538, N'INDIA_CITIES_TOWN_STATE', N'Urmar Tanda', N'Punjab', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1539, N'INDIA_CITIES_TOWN_STATE', N'Lonar', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1540, N'INDIA_CITIES_TOWN_STATE', N'Powayan', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1541, N'INDIA_CITIES_TOWN_STATE', N'P.N.Patti', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1542, N'INDIA_CITIES_TOWN_STATE', N'Palampur', N'Himachal Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1543, N'INDIA_CITIES_TOWN_STATE', N'Srisailam Project (Right Flank Colony) Township', N'Andhra Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1544, N'INDIA_CITIES_TOWN_STATE', N'Sindagi', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1545, N'INDIA_CITIES_TOWN_STATE', N'Sandi', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1546, N'INDIA_CITIES_TOWN_STATE', N'Vaikom', N'Kerala', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1547, N'INDIA_CITIES_TOWN_STATE', N'Malda', N'West Bengal', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1548, N'INDIA_CITIES_TOWN_STATE', N'Tharangambadi', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1549, N'INDIA_CITIES_TOWN_STATE', N'Sakaleshapura', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1550, N'INDIA_CITIES_TOWN_STATE', N'Lalganj', N'Bihar', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1551, N'INDIA_CITIES_TOWN_STATE', N'Malkangiri', N'Odisha', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1552, N'INDIA_CITIES_TOWN_STATE', N'Rapar', N'Gujarat', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1553, N'INDIA_CITIES_TOWN_STATE', N'Mauganj', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1554, N'INDIA_CITIES_TOWN_STATE', N'Todabhim', N'Rajasthan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1555, N'INDIA_CITIES_TOWN_STATE', N'Srinivaspur', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1556, N'INDIA_CITIES_TOWN_STATE', N'Murliganj', N'Bihar', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1557, N'INDIA_CITIES_TOWN_STATE', N'Reengus', N'Rajasthan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1558, N'INDIA_CITIES_TOWN_STATE', N'Sawantwadi', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1559, N'INDIA_CITIES_TOWN_STATE', N'Tittakudi', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1560, N'INDIA_CITIES_TOWN_STATE', N'Lilong', N'Manipur', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1561, N'INDIA_CITIES_TOWN_STATE', N'Rajaldesar', N'Rajasthan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1562, N'INDIA_CITIES_TOWN_STATE', N'Pathardi', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1563, N'INDIA_CITIES_TOWN_STATE', N'Achhnera', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1564, N'INDIA_CITIES_TOWN_STATE', N'Pacode', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1565, N'INDIA_CITIES_TOWN_STATE', N'Naraura', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1566, N'INDIA_CITIES_TOWN_STATE', N'Nakur', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1567, N'INDIA_CITIES_TOWN_STATE', N'Palai', N'Kerala', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1568, N'INDIA_CITIES_TOWN_STATE', N'Morinda, India', N'Punjab', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1569, N'INDIA_CITIES_TOWN_STATE', N'Manasa', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1570, N'INDIA_CITIES_TOWN_STATE', N'Nainpur', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1571, N'INDIA_CITIES_TOWN_STATE', N'Sahaspur', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1572, N'INDIA_CITIES_TOWN_STATE', N'Pauni', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1573, N'INDIA_CITIES_TOWN_STATE', N'Prithvipur', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1574, N'INDIA_CITIES_TOWN_STATE', N'Ramtek', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1575, N'INDIA_CITIES_TOWN_STATE', N'Silapathar', N'Assam', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1576, N'INDIA_CITIES_TOWN_STATE', N'Songadh', N'Gujarat', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1577, N'INDIA_CITIES_TOWN_STATE', N'Safipur', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1578, N'INDIA_CITIES_TOWN_STATE', N'Sohagpur', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1579, N'INDIA_CITIES_TOWN_STATE', N'Mul', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1580, N'INDIA_CITIES_TOWN_STATE', N'Sadulshahar', N'Rajasthan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1581, N'INDIA_CITIES_TOWN_STATE', N'Phillaur', N'Punjab', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1582, N'INDIA_CITIES_TOWN_STATE', N'Sambhar', N'Rajasthan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1583, N'INDIA_CITIES_TOWN_STATE', N'Prantij', N'Rajasthan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1584, N'INDIA_CITIES_TOWN_STATE', N'Nagla', N'Uttarakhand', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1585, N'INDIA_CITIES_TOWN_STATE', N'Pattran', N'Punjab', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1586, N'INDIA_CITIES_TOWN_STATE', N'Mount Abu', N'Rajasthan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1587, N'INDIA_CITIES_TOWN_STATE', N'Reoti', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1588, N'INDIA_CITIES_TOWN_STATE', N'Tenu dam-cum-Kathhara', N'Jharkhand', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1589, N'INDIA_CITIES_TOWN_STATE', N'Panchla', N'West Bengal', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1590, N'INDIA_CITIES_TOWN_STATE', N'Sitarganj', N'Uttarakhand', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1591, N'INDIA_CITIES_TOWN_STATE', N'Pasighat', N'Arunachal Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1592, N'INDIA_CITIES_TOWN_STATE', N'Motipur', N'Bihar', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1593, N'INDIA_CITIES_TOWN_STATE', N'O'' Valley', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1594, N'INDIA_CITIES_TOWN_STATE', N'Raghunathpur', N'West Bengal', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1595, N'INDIA_CITIES_TOWN_STATE', N'Suriyampalayam', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1596, N'INDIA_CITIES_TOWN_STATE', N'Qadian', N'Punjab', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1597, N'INDIA_CITIES_TOWN_STATE', N'Rairangpur', N'Odisha', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1598, N'INDIA_CITIES_TOWN_STATE', N'Silvassa', N'Dadra and Nagar Haveli', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1599, N'INDIA_CITIES_TOWN_STATE', N'Nowrozabad (Khodargama)', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1600, N'INDIA_CITIES_TOWN_STATE', N'Mangrol', N'Rajasthan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1601, N'INDIA_CITIES_TOWN_STATE', N'Soyagaon', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1602, N'INDIA_CITIES_TOWN_STATE', N'Sujanpur', N'Punjab', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1603, N'INDIA_CITIES_TOWN_STATE', N'Manihari', N'Bihar', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1604, N'INDIA_CITIES_TOWN_STATE', N'Sikanderpur', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1605, N'INDIA_CITIES_TOWN_STATE', N'Mangalvedhe', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1606, N'INDIA_CITIES_TOWN_STATE', N'Phulera', N'Rajasthan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1607, N'INDIA_CITIES_TOWN_STATE', N'Ron', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1608, N'INDIA_CITIES_TOWN_STATE', N'Sholavandan', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1609, N'INDIA_CITIES_TOWN_STATE', N'Saidpur', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1610, N'INDIA_CITIES_TOWN_STATE', N'Shamgarh', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1611, N'INDIA_CITIES_TOWN_STATE', N'Thammampatti', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1612, N'INDIA_CITIES_TOWN_STATE', N'Maharajpur', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1613, N'INDIA_CITIES_TOWN_STATE', N'Multai', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1614, N'INDIA_CITIES_TOWN_STATE', N'Mukerian', N'Punjab', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1615, N'INDIA_CITIES_TOWN_STATE', N'Sirsi', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1616, N'INDIA_CITIES_TOWN_STATE', N'Purwa', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1617, N'INDIA_CITIES_TOWN_STATE', N'Sheohar', N'Bihar', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1618, N'INDIA_CITIES_TOWN_STATE', N'Namagiripettai', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1619, N'INDIA_CITIES_TOWN_STATE', N'Parasi', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1620, N'INDIA_CITIES_TOWN_STATE', N'Lathi', N'Gujarat', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1621, N'INDIA_CITIES_TOWN_STATE', N'Lalganj', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1622, N'INDIA_CITIES_TOWN_STATE', N'Narkhed', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1623, N'INDIA_CITIES_TOWN_STATE', N'Mathabhanga', N'West Bengal', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1624, N'INDIA_CITIES_TOWN_STATE', N'Shendurjana', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1625, N'INDIA_CITIES_TOWN_STATE', N'Peravurani', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1626, N'INDIA_CITIES_TOWN_STATE', N'Mariani', N'Assam', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1627, N'INDIA_CITIES_TOWN_STATE', N'Phulpur', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1628, N'INDIA_CITIES_TOWN_STATE', N'Rania', N'Haryana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1629, N'INDIA_CITIES_TOWN_STATE', N'Pali', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1630, N'INDIA_CITIES_TOWN_STATE', N'Pachore', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1631, N'INDIA_CITIES_TOWN_STATE', N'Parangipettai', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1632, N'INDIA_CITIES_TOWN_STATE', N'Pudupattinam', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1633, N'INDIA_CITIES_TOWN_STATE', N'Panniyannur', N'Kerala', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1634, N'INDIA_CITIES_TOWN_STATE', N'Maharajganj', N'Bihar', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1635, N'INDIA_CITIES_TOWN_STATE', N'Rau', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1636, N'INDIA_CITIES_TOWN_STATE', N'Monoharpur', N'West Bengal', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1637, N'INDIA_CITIES_TOWN_STATE', N'Mandawa', N'Rajasthan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1638, N'INDIA_CITIES_TOWN_STATE', N'Marigaon', N'Assam', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1639, N'INDIA_CITIES_TOWN_STATE', N'Pallikonda', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1640, N'INDIA_CITIES_TOWN_STATE', N'Pindwara', N'Rajasthan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1641, N'INDIA_CITIES_TOWN_STATE', N'Shishgarh', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1642, N'INDIA_CITIES_TOWN_STATE', N'Patur', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1643, N'INDIA_CITIES_TOWN_STATE', N'Mayang Imphal', N'Manipur', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1644, N'INDIA_CITIES_TOWN_STATE', N'Mhowgaon', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1645, N'INDIA_CITIES_TOWN_STATE', N'Guruvayoor', N'Kerala', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1646, N'INDIA_CITIES_TOWN_STATE', N'Mhaswad', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1647, N'INDIA_CITIES_TOWN_STATE', N'Sahawar', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1648, N'INDIA_CITIES_TOWN_STATE', N'Sivagiri', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1649, N'INDIA_CITIES_TOWN_STATE', N'Mundargi', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1650, N'INDIA_CITIES_TOWN_STATE', N'Punjaipugalur', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1651, N'INDIA_CITIES_TOWN_STATE', N'Kailasahar', N'Tripura', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1652, N'INDIA_CITIES_TOWN_STATE', N'Samthar', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1653, N'INDIA_CITIES_TOWN_STATE', N'Sakti', N'Chhattisgarh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1654, N'INDIA_CITIES_TOWN_STATE', N'Sadalagi', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1655, N'INDIA_CITIES_TOWN_STATE', N'Silao', N'Bihar', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1656, N'INDIA_CITIES_TOWN_STATE', N'Mandalgarh', N'Rajasthan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1657, N'INDIA_CITIES_TOWN_STATE', N'Loha', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1658, N'INDIA_CITIES_TOWN_STATE', N'Pukhrayan', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1659, N'INDIA_CITIES_TOWN_STATE', N'Padmanabhapuram', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1660, N'INDIA_CITIES_TOWN_STATE', N'Belonia', N'Tripura', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1661, N'INDIA_CITIES_TOWN_STATE', N'Saiha', N'Mizoram', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1662, N'INDIA_CITIES_TOWN_STATE', N'Srirampore', N'West Bengal', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1663, N'INDIA_CITIES_TOWN_STATE', N'Talwara', N'Punjab', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1664, N'INDIA_CITIES_TOWN_STATE', N'Puthuppally', N'Kerala', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1665, N'INDIA_CITIES_TOWN_STATE', N'Khowai', N'Tripura', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1666, N'INDIA_CITIES_TOWN_STATE', N'Vijaypur', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1667, N'INDIA_CITIES_TOWN_STATE', N'Takhatgarh', N'Rajasthan', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1668, N'INDIA_CITIES_TOWN_STATE', N'Thirupuvanam', N'Tamil Nadu', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1669, N'INDIA_CITIES_TOWN_STATE', N'Adra', N'West Bengal', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1670, N'INDIA_CITIES_TOWN_STATE', N'Piriyapatna', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1671, N'INDIA_CITIES_TOWN_STATE', N'Obra', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1672, N'INDIA_CITIES_TOWN_STATE', N'Adalaj', N'Gujarat', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1673, N'INDIA_CITIES_TOWN_STATE', N'Nandgaon', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1674, N'INDIA_CITIES_TOWN_STATE', N'Barh', N'Bihar', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1675, N'INDIA_CITIES_TOWN_STATE', N'Chhapra', N'Gujarat', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1676, N'INDIA_CITIES_TOWN_STATE', N'Panamattom', N'Kerala', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1677, N'INDIA_CITIES_TOWN_STATE', N'Niwai', N'Uttar Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1678, N'INDIA_CITIES_TOWN_STATE', N'Bageshwar', N'Uttarakhand', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1679, N'INDIA_CITIES_TOWN_STATE', N'Tarbha', N'Odisha', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1680, N'INDIA_CITIES_TOWN_STATE', N'Adyar', N'Karnataka', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1681, N'INDIA_CITIES_TOWN_STATE', N'Narsinghgarh', N'Madhya Pradesh', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1682, N'INDIA_CITIES_TOWN_STATE', N'Warud', N'Maharashtra', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1683, N'INDIA_CITIES_TOWN_STATE', N'Asarganj', N'Bihar', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1684, N'INDIA_CITIES_TOWN_STATE', N'Sarsod', N'Haryana', 0, CAST(N'2020-03-23' AS Date), CAST(N'2020-03-23' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1685, N'EVENT_TYPE', N'MV', N'MOVIE', 0, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1686, N'GENRE_TYPE', N'TH', N'THRILLER', 0, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1687, N'GENRE_TYPE', N'HISTORY-TODAY', N'HISTORY-TODAY', 0, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1688, N'GENRE_TYPE', N'DETECTIVE', N'DETECTIVE', 0, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1689, N'GENRE_TYPE', N'HORROR', N'HORROR', 0, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1690, N'GENRE_TYPE', N'VILLAGE', N'VILLAGE', 0, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1691, N'GENRE_TYPE', N'SCIENCE FICTION', N'SCIENCE FICTION', 0, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1692, N'GENRE_TYPE', N'FANTASY', N'FANTASY', 0, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1693, N'GENRE_TYPE', N'COMEDY', N'COMEDY', 0, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1694, N'GENRE_TYPE', N'CRIME', N'CRIME', 0, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1695, N'GENRE_TYPE', N'FAMILY DRAMA', N'FAMILY DRAMA', 0, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1696, N'GENRE_TYPE', N'COP STORY', N'COP STORY', 0, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1697, N'GENRE_TYPE', N'LOVE', N'LOVE', 0, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1698, N'ROLE_TYPE', N'Director', N'Director', 0, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1699, N'ROLE_TYPE', N'Heroin', N'Heroin', 0, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1700, N'ROLE_TYPE', N'Music Director', N'Music Director', 0, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1701, N'ROLE_TYPE', N'Cinematographer', N'Cinematographer', 0, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1702, N'ROLE_TYPE', N'Editor', N'Editor', 0, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1703, N'ROLE_TYPE', N'Choreography', N'Choreography', 0, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1704, N'ROLE_TYPE', N'Costume Designer', N'Costume Designer', 0, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1705, N'ROLE_TYPE', N'Assistant Director', N'Assistant Director', 0, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1706, N'ROLE_TYPE', N'Producer', N'Producer', 0, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date))
GO
INSERT [dbo].[MasterData] ([Id], [Code], [Code_Value], [Code_Description], [IsHidden], [AddedOn], [ModifiedOn]) VALUES (1707, N'ROLE_TYPE', N'Hero', N'Hero', 0, CAST(N'2020-05-02' AS Date), CAST(N'2020-05-02' AS Date))
GO
SET IDENTITY_INSERT [dbo].[MasterData] OFF
GO
INSERT [dbo].[People] ([Id], [Name], [FirstName], [LastName], [DOB], [Place], [District], [State], [Country], [Height], [Weight], [School], [College], [DOD]) VALUES (1, N'Joseph Vijay Chandrasekhar', N'Joseph Vijay', N'Chandrasekhar', CAST(N'1974-06-22' AS Date), N'475', 475, 464, 103, CAST(1.77 AS Decimal(4, 2)), 73, N'Fathima Matriculation Higher Secondary', N'Loyola College', NULL)
GO
INSERT [dbo].[People] ([Id], [Name], [FirstName], [LastName], [DOB], [Place], [District], [State], [Country], [Height], [Weight], [School], [College], [DOD]) VALUES (2, N'Vishal Krishna', N'Vishal', N'Krishna', CAST(N'1977-08-29' AS Date), N'475', 475, 464, 103, CAST(1.85 AS Decimal(4, 2)), 73, N'Don Bosco Matriculation Higher Secondary School', N'Loyola College', NULL)
GO
INSERT [dbo].[People] ([Id], [Name], [FirstName], [LastName], [DOB], [Place], [District], [State], [Country], [Height], [Weight], [School], [College], [DOD]) VALUES (3, N'Siva Karthikeyan', N'Siva', N'Karthikeyan', CAST(N'1985-02-17' AS Date), N'522', 522, 464, 103, CAST(1.75 AS Decimal(4, 2)), 69, N'Campion Anglo-Indian Higher Secondary School', N'J. J. College of Engineering and Technology', NULL)
GO
INSERT [dbo].[People] ([Id], [Name], [FirstName], [LastName], [DOB], [Place], [District], [State], [Country], [Height], [Weight], [School], [College], [DOD]) VALUES (4, N'Rajinikanth', N'Shivaji Rao', N'Gaekwad', CAST(N'1950-12-12' AS Date), N'472', 472, 450, 103, CAST(1.73 AS Decimal(4, 2)), 75, N'Gavipuram Government Kannada Model Primary School', N'MGR Government Film and Television Institute', NULL)
GO
INSERT [dbo].[People] ([Id], [Name], [FirstName], [LastName], [DOB], [Place], [District], [State], [Country], [Height], [Weight], [School], [College], [DOD]) VALUES (5, N'Dhanush', N'Dhanush', N'Kasthuri Rajahanush ', CAST(N'1982-07-28' AS Date), N'822', 822, 464, 103, CAST(1.73 AS Decimal(4, 2)), 70, N'St Johns Matriculation Higher Secondary School', N'TBU', NULL)
GO
INSERT [dbo].[People] ([Id], [Name], [FirstName], [LastName], [DOB], [Place], [District], [State], [Country], [Height], [Weight], [School], [College], [DOD]) VALUES (6, N'Suriya', N'Saravanan', N'Sivakumar', CAST(N'1975-07-23' AS Date), N'475', 475, 464, 103, CAST(1.70 AS Decimal(4, 2)), 72, N'Padma Seshadri Bala Bhavan ', N'Loyola College', NULL)
GO
INSERT [dbo].[People] ([Id], [Name], [FirstName], [LastName], [DOB], [Place], [District], [State], [Country], [Height], [Weight], [School], [College], [DOD]) VALUES (7, N'MGR', N'Maruthur Gopalan', N'Ramachandran', CAST(N'1917-01-17' AS Date), N'210', 210, 210, 210, CAST(1.63 AS Decimal(4, 2)), 65, NULL, NULL, CAST(N'1987-12-24' AS Date))
GO
INSERT [dbo].[People] ([Id], [Name], [FirstName], [LastName], [DOB], [Place], [District], [State], [Country], [Height], [Weight], [School], [College], [DOD]) VALUES (8, N'Ajith Kumar', N'Ajith Kumar', N'Subramaniam', CAST(N'1971-05-01' AS Date), N'478', 478, 435, 103, CAST(1.75 AS Decimal(4, 2)), 80, N'Asan Memorial Senior Secondary School
', N'TBU', NULL)
GO
INSERT [dbo].[People] ([Id], [Name], [FirstName], [LastName], [DOB], [Place], [District], [State], [Country], [Height], [Weight], [School], [College], [DOD]) VALUES (9, N'Narendra Modi', N'Narendra ', N' Modi', CAST(N'1950-09-17' AS Date), N'1429', 1429, 445, 103, CAST(1.70 AS Decimal(4, 2)), 75, N'Vadnagar higher secondary education i', N'TBU', NULL)
GO
INSERT [dbo].[People] ([Id], [Name], [FirstName], [LastName], [DOB], [Place], [District], [State], [Country], [Height], [Weight], [School], [College], [DOD]) VALUES (10, N'Sagayam', N'Ubagarampillai', N'Sagayam', CAST(N'1962-03-22' AS Date), N'773', 773, 464, 103, NULL, NULL, N'Government Higher secondary school, Ellaippatti.', N'University of Madras', NULL)
GO
INSERT [dbo].[People] ([Id], [Name], [FirstName], [LastName], [DOB], [Place], [District], [State], [Country], [Height], [Weight], [School], [College], [DOD]) VALUES (11, N'Kamal', N'Kamal', N'Haasan', CAST(N'1954-11-07' AS Date), N'856', 856, 464, 103, CAST(1.65 AS Decimal(4, 2)), 76, N'Hindu Higher Secondary School', N'Sai Ram Engineering College', NULL)
GO
INSERT [dbo].[People] ([Id], [Name], [FirstName], [LastName], [DOB], [Place], [District], [State], [Country], [Height], [Weight], [School], [College], [DOD]) VALUES (12, N'Mahesh ', N'Mahesh ', N'Babu', CAST(N'1975-08-09' AS Date), N'464', 464, 464, 103, CAST(1.88 AS Decimal(4, 2)), 70, N'TBU', N'Loyola College', NULL)
GO
INSERT [dbo].[People] ([Id], [Name], [FirstName], [LastName], [DOB], [Place], [District], [State], [Country], [Height], [Weight], [School], [College], [DOD]) VALUES (13, N'S.A.Chandrasekhar', N'Chandrasekhar', N'', CAST(N'1945-07-02' AS Date), N'968', 968, 464, 103, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[People] ([Id], [Name], [FirstName], [LastName], [DOB], [Place], [District], [State], [Country], [Height], [Weight], [School], [College], [DOD]) VALUES (14, N'PS.Veerappa', N'Veerappa', N' ', CAST(N'1911-09-10' AS Date), N'507', 507, 464, 103, NULL, NULL, NULL, NULL, CAST(N'1998-09-11' AS Date))
GO
INSERT [dbo].[People] ([Id], [Name], [FirstName], [LastName], [DOB], [Place], [District], [State], [Country], [Height], [Weight], [School], [College], [DOD]) VALUES (15, N'Vijayakanth', N'Vijayaraj', N'Alagarswami', CAST(N'1952-08-25' AS Date), N'1074', 511, 464, 103, CAST(1.73 AS Decimal(4, 2)), 172, N'Devakottai De Britto High School', NULL, NULL)
GO
INSERT [dbo].[People] ([Id], [Name], [FirstName], [LastName], [DOB], [Place], [District], [State], [Country], [Height], [Weight], [School], [College], [DOD]) VALUES (16, N'Shankar', N'Shankar', NULL, NULL, N'475', 475, 464, 103, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[People] ([Id], [Name], [FirstName], [LastName], [DOB], [Place], [District], [State], [Country], [Height], [Weight], [School], [College], [DOD]) VALUES (17, N'Ganesh', N'Ganesh', NULL, NULL, N'475', 475, 464, 103, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[People] ([Id], [Name], [FirstName], [LastName], [DOB], [Place], [District], [State], [Country], [Height], [Weight], [School], [College], [DOD]) VALUES (18, N'Viji', N'Viji', N'Aswath', NULL, N'475', 475, 464, 103, NULL, NULL, NULL, NULL, CAST(N'2000-11-27' AS Date))
GO
INSERT [dbo].[People] ([Id], [Name], [FirstName], [LastName], [DOB], [Place], [District], [State], [Country], [Height], [Weight], [School], [College], [DOD]) VALUES (19, N'M. Kesavan', N'Kesavan', NULL, NULL, N'', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[People] ([Id], [Name], [FirstName], [LastName], [DOB], [Place], [District], [State], [Country], [Height], [Weight], [School], [College], [DOD]) VALUES (20, N'Gautham Raju', N'Gautham', N'Raju', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
ALTER TABLE [dbo].[EventDetails]  WITH CHECK ADD FOREIGN KEY([EventTypeId])
REFERENCES [dbo].[MasterData] ([Id])
GO
ALTER TABLE [dbo].[EventDetails]  WITH CHECK ADD FOREIGN KEY([EventId])
REFERENCES [dbo].[Event] ([Id])
GO
ALTER TABLE [dbo].[EventDetails]  WITH CHECK ADD FOREIGN KEY([GenreTypeId])
REFERENCES [dbo].[MasterData] ([Id])
GO
ALTER TABLE [dbo].[EventRating]  WITH CHECK ADD FOREIGN KEY([EventId])
REFERENCES [dbo].[Event] ([Id])
GO
USE [master]
GO
ALTER DATABASE [Cosmos] SET  READ_WRITE 
GO
