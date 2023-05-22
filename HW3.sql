/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, GROUP BY, HAVING".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Посчитать среднюю цену товара, общую сумму продажи по месяцам.
Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Средняя цена за месяц по всем товарам
* Общая сумма продаж за месяц

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

 select 
 datepart(year,FinalizationDate) as 'Год продажи',
 month(FinalizationDate) as 'месяц продажи',
 avg(TransactionAmount) as 'средняя ценв продажи',
 sum(TransactionAmount) as 'сумма продажи'
 from sales.CustomerTransactions
 where InvoiceID is not null
 and IsFinalized=1
 group by datepart(year,FinalizationDate), month(FinalizationDate)
 order by datepart(year,FinalizationDate) desc, month(FinalizationDate)  asc

/*
2. Отобразить все месяцы, где общая сумма продаж превысила 4 600 000

Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Общая сумма продаж

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

select 
 datepart(year,FinalizationDate) as 'Год продажи',
 month(FinalizationDate) as 'месяц продажи',
 sum(TransactionAmount) as 'сумма продажи'
 from sales.CustomerTransactions
 where InvoiceID is not null
 and IsFinalized=1
 group by datepart(year,FinalizationDate), month(FinalizationDate)
 having sum(TransactionAmount)>4600000
 order by datepart(year,FinalizationDate) desc, month(FinalizationDate)  asc

/*
3. Вывести сумму продаж, дату первой продажи
и количество проданного по месяцам, по товарам,
продажи которых менее 50 ед в месяц.
Группировка должна быть по году,  месяцу, товару.

Вывести:
* Год продажи
* Месяц продажи
* Наименование товара
* Сумма продаж
* Дата первой продажи
* Количество проданного

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/


 select
 datepart(year,FinalizationDate) as 'Год продажи',
 month(FinalizationDate) as 'месяц продажи',
 StockItemName as 'наименование товара',
 sum(TransactionAmount) as 'сумма продажи',
 min(FinalizationDate) as 'Дата первой продажи',
 sum(Quantity) as 'кол-во проданного'
 from sales.CustomerTransactions a -- сумма продажи и дата
 join sales.InvoiceLines b on b.InvoiceID=a.InvoiceID --- кол-во проданного товара
 join  Warehouse.StockItems c on b.StockItemID=c.StockItemID -- название тавара
 where a.InvoiceID is not null and IsFinalized=1
 group by datepart(year,FinalizationDate), month(FinalizationDate),StockItemName
 having sum(Quantity)<50
 order by datepart(year,FinalizationDate) desc, month(FinalizationDate),StockItemName

-- ---------------------------------------------------------------------------
-- Опционально
-- ---------------------------------------------------------------------------
/*
Написать запросы 2-3 так, чтобы если в каком-то месяце не было продаж,
то этот месяц также отображался бы в результатах, но там были нули.
*/
