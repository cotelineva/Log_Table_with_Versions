/*1:create table
*2:add column
*3:modify type column
*4:default constraint
*5:foreign key constraint
*/

--1
alter procedure createTable
		(@table_name varchar(50),
		@col1_name varchar(20),
		@col1_type varchar(20))
	as
		declare @nr int = (select max(Versions.nr_crt) from Versions)
		set @nr = @nr + 1

		insert into Versions (nr_crt,procedureName,tableName,columnName,typeName)
		values (@nr,'createTable',@table_name, @col1_name, @col1_type);

		delete from crtVersion
		where crtVersion.nr = (select top 1 crtVersion.nr
								from crtVersion
								order by crtVersion.nr desc)

		insert into crtVersion (nr)
		values (@nr)

		declare @query1 varchar(500)
		set @query1 = 'create table '+@table_name + '( '+@col1_name+' '+@col1_type +' not null, primary key('+@col1_name+'))'
		exec (@query1)
		print @query1
	go

exec createTable 'Momo', 'ID', 'int'
  


--2
alter procedure addColumn
			(@table_name varchar(50),
			@col_name varchar(20),
			@col_type varchar(20))
	as
		declare @nr int = (select max(Versions.nr_crt) from Versions)
		set @nr = @nr + 1

		insert into Versions (nr_crt,procedureName,tableName,columnName,typeName)
		values (@nr,'addColumn',@table_name, @col_name, @col_type);

		delete from crtVersion
		where crtVersion.nr = (select top 1 crtVersion.nr
								from crtVersion
								order by crtVersion.nr desc)

		insert into crtVersion (nr)
		values (@nr)

		declare @query2 varchar(500)
		set @query2 = 'alter table '+@table_name +' add '+@col_name+' '+@col_type+';'
		exec (@query2)
		print @query2
	go
			
exec addColumn 'Yoyo', 'City', 'varchar(20)'


--3
alter procedure modifyDataType
			(@table_name varchar(50),
			@col1_name varchar(20),
			@col1_old_type varchar(20),
			@col1_new_type varchar(20))
	as
		declare @nr int = (select max(Versions.nr_crt) from Versions)
		set @nr = @nr + 1

		insert into Versions (nr_crt,procedureName,tableName,columnName,typeName,typeName2)
		values (@nr,'modifyDataType',@table_name, @col1_name, @col1_old_type,@col1_new_type);

		delete from crtVersion
		where crtVersion.nr = (select top 1 crtVersion.nr
								from crtVersion
								order by crtVersion.nr desc)

		insert into crtVersion (nr)
		values (@nr)
		
		declare @query3 varchar(500)
		set @query3 = 'alter table '+@table_name +' alter column '+@col1_name+' '+@col1_new_type
		print @query3
		exec (@query3)
	go

exec modifyDataType 'Yoyo', 'City','varchar(20)','date'


--4
alter procedure defaultConstraint
			(@table_name varchar(50),
			@col1_name varchar(20),
			@value varchar(30))
	as
		declare @nr int = (select max(Versions.nr_crt) from Versions)
		set @nr = @nr + 1

		insert into Versions (nr_crt,procedureName,tableName,columnName,typeName)
		values (@nr,'defaultConstraint',@table_name, @col1_name,@value);

		delete from crtVersion
		where crtVersion.nr = (select top 1 crtVersion.nr
								from crtVersion
								order by crtVersion.nr desc)

		insert into crtVersion (nr)
		values (@nr)
		
		declare @query4 varchar(500)
		set @query4 = 'alter table '+@table_name +' add constraint df_'+@col1_name+' default '''+@value+''' for '+@col1_name
		exec (@query4)
		print @query4
	go

exec defaultConstraint 'Yoyo','City','1-1-2000'



--5
alter procedure FKConstraint		
			(@table1_name varchar(50),
			@table2_name varchar(50),
			@col1_name varchar(20),
			@col2_name varchar(20))
	as
		declare @nr int = (select max(Versions.nr_crt) from Versions)
		set @nr = @nr + 1

		insert into Versions (nr_crt,procedureName,tableName,columnName,typeName,typeName2)
		values (@nr,'FKConstraint',@table1_name,@table2_name, @col1_name, @col2_name);

		delete from crtVersion
		where crtVersion.nr = (select top 1 crtVersion.nr
								from crtVersion
								order by crtVersion.nr desc)

		insert into crtVersion (nr)
		values (@nr)

		declare @query5 varchar(500)
		set @query5 = 'alter table '+@table1_name+
					' add constraint FK_'+@table1_name+ @table2_name+
					' foreign key('+@col1_name+') references '+@table2_name+'('+@col2_name+')'
		print @query5
		exec (@query5)
	go

exec FKConstraint 'Yoyo','Momo','ID','id'


------------------------------------------------------------------------------------------------

--1 rollback
create procedure createTableRollback
			(@table_name varchar(50))
	as
		declare @query6 varchar(500)
		set @query6 = 'drop table ' + @table_name
		print @query6
		exec(@query6)
	go

exec createTableRollback 'Yoyo'


--2 rollback
create procedure addColumnRollback
			(@table_name varchar(50),
			@col_name varchar(20))
	as
		declare @query7 varchar(500)
		set @query7 = 'alter table '+@table_name+' drop column '+@col_name
		print @query7
		exec(@query7)
	go

exec addColumnRollback 'Yoyo', 'lastName'



--3 rollback
create procedure modifyDataTypeRollback
			(@table_name varchar(50),
			@col1_name varchar(20),
			@col1_old_type varchar(20),
			@col1_new_type varchar(20))
	as
		declare @query3 varchar(500)
		set @query3 = 'alter table '+@table_name +' alter column '+@col1_name+' '+@col1_old_type
		print @query3
		exec (@query3)
	go

exec modifyDataTypeRollback 'Manager', 'lastName','char(20)','varchar(20)'


--4 rollback
create procedure defaultConstraintRollback
			(@table_name varchar(50),
			@col_name varchar(20))
	as
		declare @query9 varchar(max)
		set @query9 = 'alter table '+@table_name+' drop constraint df_'+@col_name
		print @query9
		exec(@query9)
	go

exec defaultConstraintRollback 'Yoyo','City'



--5 rollback
create procedure FKConstraintRollback
			(@table1_name varchar(50),
			@table2_name varchar(50))
	as
		declare @query10 varchar(max)
		set @query10 = 'alter table '+@table1_name+' drop constraint fk_'+@table1_name+@table2_name
		print @query10
		exec(@query10)
	go

exec FKConstraintRollback 'Yoyo','Persons'