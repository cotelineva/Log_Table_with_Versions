exec createTable 'crtVersion','nr','int'

exec createTable 'Versions','nr_crt','int'

exec addColumn 'Versions','procedureName','varchar(30)'

exec addColumn 'Versions', 'tableName', 'varchar(20)'

exec addColumn 'Versions', 'columnName', 'varchar(20)'

exec addColumn 'Versions', 'typeName', 'varchar(20)'



alter procedure goToVersion
				(@version int)
	as
		declare @x int = (select max(Versions.nr_crt) from Versions) --max Version
		declare @y int = (select top 1 crtVersion.nr from crtVersion order by nr desc) --crt Version

		if @version > @x
		begin
			print 'There are not that many versions.'
		end
		else if @version < @y --subtract (for decreasing the crt version)
		begin
			declare @i int = @y

			while @i > @version
			begin
				declare @procName varchar(40) = 
							(select Versions.procedureName
							from Versions
							where Versions.nr_crt = @i)
				declare @tName varchar(40) = 
							(select Versions.tableName
							from Versions
							where Versions.nr_crt = @i)
				declare @cName varchar(40) = 
							(select Versions.columnName
							from Versions
							where Versions.nr_crt = @i)
				declare @tyName varchar(40) = 
							(select Versions.typeName
							from Versions
							where Versions.nr_crt = @i)
				declare @ty2Name varchar(40) = 
							(select Versions.typeName2
							from Versions
							where Versions.nr_crt = @i)

				if @procName = 'createTable'
					exec createTableRollback @tName
				else if @procName = 'addColumn'
					exec addColumnRollback @tName, @cName
				else if @procName = 'modifyDataType'
					exec modifyDataTypeRollback @tName,@cName,@tyName,@ty2Name
				else if @procName = 'defaultConstraint'
					exec defaultConstraintRollback @tName,@cName
				else if @procName = 'FKConstraint'
					exec FKConstraintRollback @tName,@cName	
				
				set @i = @i - 1
			end

			delete from crtVersion 
			where crtVersion.nr = (select top 1 crtVersion.nr
									from crtVersion
									order by nr desc)

			insert into crtVersion
			values (@version)
		end
		
		else if @version > @y --add (for increasing the crt version)
		begin
			declare @j int = @y
			while @j < @version
			begin
				declare @pName varchar(40) = 
							(select Versions.procedureName
							from Versions
							where Versions.nr_crt = @j + 1)
				declare @taName varchar(40) = 
							(select Versions.tableName
							from Versions
							where Versions.nr_crt = @j + 1)
				declare @coName varchar(40) = 
							(select Versions.columnName
							from Versions
							where Versions.nr_crt = @j + 1)
				declare @typName varchar(40) = 
							(select Versions.typeName
							from Versions
							where Versions.nr_crt = @j + 1)
				declare @typ2Name varchar(40) = 
							(select Versions.typeName2
							from Versions
							where Versions.nr_crt = @j + 1)

				if @pName = 'createTable'
				begin
					exec createTable @taName,@coName,@typName
					delete from Versions where Versions.nr_crt = (select top 1 Versions.nr_crt
																from Versions
																order by Versions.nr_crt desc)

				end

				else if @pName = 'addColumn'
				begin
					exec addColumn @taName,@coName,@typName
					delete from Versions where Versions.nr_crt = (select top 1 Versions.nr_crt
																from Versions
																order by Versions.nr_crt desc)

				end

				else if @pName = 'modifyDataType'
				begin
					exec modifyDataType @taName,@coName,@typName,@typ2Name 
					delete from Versions where Versions.nr_crt = (select top 1 Versions.nr_crt
																from Versions
																order by Versions.nr_crt desc)

				end

				else if @pName = 'defaultConstraint'
				begin
					exec defaultConstraint @taName,@coName,@typName
					delete from Versions where Versions.nr_crt = (select top 1 Versions.nr_crt
																from Versions
																order by Versions.nr_crt desc)

				end

				else if @pName = 'FKConstraint'
				begin
					exec FKConstraint @taName,@coName,@typName,@typ2Name
					delete from Versions where Versions.nr_crt = (select top 1 Versions.nr_crt
																from Versions
																order by Versions.nr_crt desc)

				end

				set @j = @j + 1

			end	

			delete from crtVersion 
			where crtVersion.nr = (select top 1 crtVersion.nr
									from crtVersion
									order by nr desc)

			insert into crtVersion
			values (@version)

		end
	go
