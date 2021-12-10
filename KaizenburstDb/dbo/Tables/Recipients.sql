CREATE TABLE [dbo].[Recipients] (
    [ID]                 FLOAT (53)     NULL,
    [Name]               NVARCHAR (255) NULL,
    [address]            NVARCHAR (255) NULL,
    [UserName]           NVARCHAR (255) NULL,
    [Age]                FLOAT (53)     NULL,
    [GroupId]            FLOAT (53)     NULL,
    [GroupMailingListId] NVARCHAR (255) NULL,
    [UnsubscribeEmail]   NVARCHAR (255) NULL,
    [SubscriptionEmail]  BIT            NOT NULL,
    [GenderId]           FLOAT (53)     NULL,
    [Surname]            NVARCHAR (255) NULL
);

