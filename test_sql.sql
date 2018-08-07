/*  Generalidades de  SQLSERVER */

/* Crear tablas */
create table usuarios (
  nombre varchar(30),
  clave varchar(10)
 );
/*Insercion de registros*/
insert into usuarios (nombre, clave) values ('Mariano','payaso');
insert into usuarios (clave, nombre) values ('River','Juan');
/* conteo de registros */
select nombre, count(*) as total from usuarios
group by clave, nombre
order by clave;
/* case y with*/
WITH name AS   
(   
select nombre, count(*) as total from usuarios
group by clave, nombre
)   
SELECT   
   CASE   
      WHEN nombre= 'Mariano' THEN 0   
      WHEN nombre= 'Juan' THEN 1   
   END   
FROM name;
/* COALESCE */

SET NOCOUNT ON;  
GO  
USE tempdb;  
IF OBJECT_ID('dbo.wages') IS NOT NULL  
    DROP TABLE wages;  
GO  
CREATE TABLE dbo.wages  
(  
    emp_id        tinyint   identity,  
    hourly_wage   decimal   NULL,  
    salary        decimal   NULL,  
    commission    decimal   NULL,  
    num_sales     tinyint   NULL  
);  
GO  
INSERT dbo.wages (hourly_wage, salary, commission, num_sales)  
VALUES  
    (10.00, NULL, NULL, NULL),  
    (20.00, NULL, NULL, NULL),  
    (30.00, NULL, NULL, NULL),  
    (40.00, NULL, NULL, NULL),  
    (NULL, 10000.00, NULL, NULL),  
    (NULL, 20000.00, NULL, NULL),  
    (NULL, 30000.00, NULL, NULL),  
    (NULL, 40000.00, NULL, NULL),  
    (NULL, NULL, 15000, 3),  
    (NULL, NULL, 25000, 2),  
    (NULL, NULL, 20000, 6),  
    (NULL, NULL, 14000, 4);  
GO  
SET NOCOUNT OFF;  
GO  
SELECT CAST(COALESCE(hourly_wage * 40 * 52,   
   salary,   
   commission * num_sales) AS money) AS 'Total Salary'   
FROM dbo.wages  
ORDER BY 'Total Salary';  
GO



/*   Ejemplo completo creacion de tablas y relaciones y condiciones para cada campo..*/
if object_id('dbo.empleados') is not null
  drop table dbo.empleados;
if object_id('dbo.secciones') is not null
   drop table dbo.secciones;
 
 create table dbo.secciones(
  codigo tinyint identity,
  nombre varchar(20),
  sueldo decimal(5,2)
   constraint CK_secciones_sueldo check (sueldo>=0),
  constraint PK_secciones primary key (codigo)
 );
 
 
 
 create table empleados(
  legajo int identity,
  documento char(8)
   constraint CK_empleados_documento check (documento like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
  sexo char(1)
   constraint CK_empleados_sexo check (sexo in ('f','m')),
  apellido varchar(20),
  nombre varchar(20),
  domicilio varchar(30),
  seccion tinyint not null,
  cantidadhijos tinyint
   constraint CK_empleados_hijos check (cantidadhijos>=0),
  estadocivil char(10)
   constraint CK_empleados_estadocivil check (estadocivil in ('casado','divorciado','soltero','viudo')),
  fechaingreso datetime,
   constraint PK_empleados primary key (legajo),
  constraint FK_empleados_seccion
   foreign key (seccion)
   references secciones(codigo)
   on update cascade,
  constraint UQ_empleados_documento
   unique(documento)
 );

insert into secciones values('Administracion',300);
insert into secciones values('Contaduría',400);
insert into secciones values('Sistemas',500);

insert into empleados values('22222222','f','Lopez','Ana','Colon 123',1,2,'casado','1990-10-10');
insert into empleados values('23333333','m','Lopez','Luis','Sucre 235',1,0,'soltero','1990-02-10');
insert into empleados values('24444444','m','Garcia','Marcos','Sarmiento 1234',2,3,'divorciado', '1998-07-12');
insert into empleados values('25555555','m','Gomez','Pablo','Bulnes 321',3,2,'casado','1998-10-09');
insert into empleados values('26666666','f','Perez','Laura','Peru 1254',3,3,'casado','2000-05-09');

if object_id('vista_empleados') is not null
  drop view vista_empleados;
  
create view vista_empleados as
  select (apellido+' '+e.nombre) as nombre,sexo,
   s.nombre as seccion, cantidadhijos
   from empleados as e
   join secciones as s
   on codigo=seccion;
   
  select seccion,count(*) as cantidad
  from vista_empleados
  group by seccion;
  
  if object_id('vista_empleados_ingreso') is not null
  drop view vista_empleados_ingreso;
  
  
  create view vista_empleados_ingreso (fecha,cantidad)
  as
  select datepart(year,fechaingreso),count(*)
   from empleados
   group by datepart(year,fechaingreso);
   
   
   select *from vista_empleados_ingreso;


/* BEGIN.... END*/
    if exists (select * from empleados )
    begin
    update empleados set apellido='Giraldo' where apellido = 'Perez';
    select 'empleados actualizado';
    end
    else
    select 'No hay registros eliminados';

/* PROCEDIMIENTOS ALMACENADOS */

if object_id('pa_empleados_limite_casados')is not null
   drop proc pa_empleados_limite_casados;

create proc pa_empleados_limite_casados
  as
   select *from empleados
   where estadocivil = 'casado';

exec pa_empleados_limite_casados;


if object_id('pa_crear_libros')is not null
   drop proc pa_crear_libros;

create procedure pa_crear_libros
  as
  if object_id('libros')is not null
   drop table libros;
  create table libros(
   codigo int identity,
   titulo varchar(40),
   autor varchar(30),
   editorial varchar(20),
   precio decimal(5,2),
   primary key(codigo)
  );

exec pa_crear_libros;

insert into libros values('Uno','Richard Bach','Planeta',15);
insert into libros values('Ilusiones','Richard Bach','Planeta',18);
insert into libros values('El aleph','Borges','Emece',25);
insert into libros values('Aprenda PHP','Mario Molina','Nuevo siglo',45);
insert into libros values('Matematica estas ahi','Paenza','Nuevo siglo',12);
insert into libros values('Java en 10 minutos','Mario Molina','Paidos',35);

select * from libros


/* Procedimientos almacenados con parametros de entrada */

if OBJECT_ID('pa_libros_autor') is not null
  drop proc pa_libros_autor;

create procedure pa_libros_autor
  @autor varchar(30) 
 as
  select titulo, editorial,precio
   from libros
   where autor= @autor;
   
exec pa_libros_autor 'Borges';

if OBJECT_ID('pa_libros_autor_editorial') is not null
  drop proc pa_libros_autor_editorial;
  
create procedure pa_libros_autor_editorial
  @autor varchar(30),
  @editorial varchar(20) 
 as
  select titulo, precio
   from libros
   where autor= @autor and
   editorial=@editorial;
   
exec pa_libros_autor_editorial 'Richard Bach','Planeta';
exec pa_libros_autor_editorial @editorial='Planeta', @autor='Richard Bach';

/* Procedimientos almacenados con parametros de entrada y salida*/

if OBJECT_ID('pa_autor_sumaypromedio') is not null
  drop proc pa_autor_sumaypromedio;
  

create procedure pa_autor_sumaypromedio
  @autor varchar(30)='%',
  @suma decimal(6,2) output,
  @promedio decimal(6,2) output
  as 
   select titulo,editorial,precio
   from libros
   where autor like @autor
  select @suma=sum(precio)
   from libros
   where autor like @autor
  select @promedio=avg(precio)
   from libros
   where autor like @autor;


 declare @s decimal(6,2), @p decimal(6,2)
 exec pa_autor_sumaypromedio 'Richard Bach', @s output, @p output
 select @s as total,
 select @p as promedio;

/* Procedimientos almacenados con parametros y return */

if OBJECT_ID('pa_libros_ingreso') is not null
  drop proc pa_libros_ingreso;

create procedure pa_libros_ingreso
  @titulo varchar(40)=null,
  @autor varchar(30)=null,
  @editorial varchar(20)=null,
  @precio decimal(5,2)=null
 as 
 if (@titulo is null) or (@autor is null)
  return 0
 else 
 begin
  insert into libros values (@titulo,@autor,@editorial,@precio)
  return 1
 end;
 
 
 declare @retorno int
 exec @retorno=pa_libros_ingreso 'El gato con botas','Anónimo'
 if @retorno = 1 
    print 'Registro ingresado...'
 else 
 select 'Registro no ingresado porque faltan datos';

/* Funciones almacenadas*/


if OBJECT_ID('f_nombreMes') is not null
  drop function f_nombreMes;

create function f_nombreMes
 (@fecha datetime='2007/01/01')
  returns varchar(10)
  as
  begin
    declare @nombre varchar(10)
    set @nombre=
     case datename(month,@fecha)
       when 'January' then 'Enero'
       when 'February' then 'Febrero'
       when 'March' then 'Marzo'
       when 'April' then 'Abril'
       when 'May' then 'Mayo'
       when 'June' then 'Junio'
       when 'July' then 'Julio'
       when 'August' then 'Agosto'
       when 'September' then 'Setiembre'
       when 'October' then 'Octubre'
       when 'November' then 'Noviembre'
       when 'December' then 'Diciembre'
     end--case
    return @nombre
 end;
 
 
 select nombre,
  dbo.f_nombreMes(fechaingreso) as 'mes de ingreso'
 from empleados;

 /* Funciones de tabla de varias instrucciones */

 if OBJECT_ID('f_ofertas') is not null
  drop function f_ofertas;
  
create function f_ofertas
 (@minimo decimal(6,2))
 returns @ofertas table-- nombre de la tabla
 --formato de la tabla
 (codigo int,
  titulo varchar(40),
  autor varchar(30),
  precio decimal(6,2)
 )
 as
 begin
   insert @ofertas
    select codigo,titulo,autor,precio
    from libros
    where precio < @minimo
   return
 end;
 
 select *from f_ofertas(30);

 /* Triggers */

 if object_id('libros') is not null
  drop table libros;

 create table libros(
  codigo int identity,
  titulo varchar(40),
  autor varchar(30),
  editorial varchar(20),
  stock int,
  constraint pk_libros primary key (codigo)
 ); 

 insert into libros values('Uno','R. Bach','Planeta',50);
 insert into libros values('Ilusiones','R. Bach','Planeta',15);
 insert into libros values('El aleph','Borges','Emece',10);
 insert into libros values('Aprenda PHP','M. Molina','Nuevo siglo',5);

 if object_id('dis_libros_actualizar') is not null
  drop trigger dis_libros_actualizar;
 
 create trigger dis_libros_actualizar
 on libros
 after update
 as
  if exists (select *from inserted where stock<0)
  begin
   update libros set stock=deleted.stock
   from libros
   join deleted
   on deleted.codigo=libros.codigo
   join inserted
   on inserted.codigo=libros.codigo
   where inserted.stock<0
  end;

 update libros set stock=stock-15;

 select *from libros;
  








