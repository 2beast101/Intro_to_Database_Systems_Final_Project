
create table account
	(id                    int AUTO_INCREMENT,
     user           	   varchar(20),
     password       	   varchar(255),
     creation_date  	   date,
     cash           	   numeric(10,2),
     primary key (id)
	);

create table stocks(
     ticker             varchar(5),
     company_name       varchar(30),
     primary key (ticker)
    );

create table lots(
     lot_num            int AUTO_INCREMENT,
     id                 int,
     ticker             varchar(4),
     num_shares         numeric(6,0),
     purchase_price     numeric(6,2),
     purchase_date      date,
     primary key (lot_num,id),
     foreign key (id) references account (id),
     foreign key (ticker) references stocks (ticker)
    );

create table price_history(
     price_date     date,
     ticker         varchar(4),
     price          numeric(6,2),
     primary key (price_date,ticker),
     foreign key (ticker) references stocks (ticker)
    ); 

create view   stock_prices(ticker, CurrentPrice) as 
     SELECT ticker, price 
     from price_history 
     where price_date = '2023-11-17';

create view  lot_value(TotalValue,ticker,Price,Previous,Shares,Basis,Lot,LotOwner,l_date) as 
     SELECT (num_shares*currentPrice),ticker,CurrentPrice,Yesterday,num_shares,(num_shares*purchase_price),lot_num,id,pDate
     from lots NATURAL JOIN (select p.ticker, p.price as currentPrice, p.price_date as pDate, o.price as Yesterday 
          from price_history as p left outer join price_history as o 
          on o.price_date = DATE_SUB(p.price_date,INTERVAL 1 DAY) AND p.ticker = o.ticker) as stockStats
     where purchase_date <= stockStats.pDate;
     
create view account_value(accVal,id,aDate) as
     SELECT IF(TotalValue IS NOT NULL,sum(TotalValue)+cash, cash), id, l_date 
     from lot_value right outer JOIN account on lot_value.LotOwner=account.id
     GROUP BY id,l_date;

create view price_movement(ticker,price, pDate, one_day, three_day) as 
     select day_history.Ticker, day_history.today,day_history.pDate,day_history.yesterday, t.price as three_day from 
     (Select p.ticker as Ticker, p.price as today, p.price_date as pDate, o.price as yesterday
     from price_history as p left outer join price_history as o
     on o.price_date = DATE_SUB(p.price_date,INTERVAL 1 DAY) AND p.ticker = o.ticker) as day_history left outer join price_history as t
     	on t.price_date = DATE_SUB(pDate,INTERVAL 3 DAY) and t.ticker = day_history.Ticker;



/*
create view  historic_lot_value(date,TotalValue,ticker,Price,Shares,Lot,LotOwner) as 
     SELECT price_date,(num_shares*price),ticker,price,num_shares,lot_num,id 
     from lots NATURAL JOIN price_history;

create view historic_account_value(date,accVal,id) as
     SELECT date, IF(TotalValue IS NOT NULL,sum(TotalValue)+cash,cash), id
     from historic_lot_value right outer join account on historic_lot_value.LotOwner=account.id
     GROUP BY date;
*/



