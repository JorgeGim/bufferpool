Create table if not exists bufferpool(nro_frame int,
pfree boolean,
dirty boolean,
nro_disk_page int,
last_touch timestamp);

Create table if not exists traza(tiempo serial, nro_disk_page int);

create type registro_desalojo as (frame integer,valorDesalojado integer);

delete from bufferpool;
delete from traza;
insert into bufferpool values(1,true,false,1,clock_timestamp());
insert into bufferpool values(2,true,false,2,clock_timestamp());
insert into bufferpool values(3,true,false,3,clock_timestamp());
insert into bufferpool values(4,true,false,4,clock_timestamp());
						  
CREATE OR REPLACE FUNCTION public.get_disk_page(nro_pag integer)
	RETURNS integer
	LANGUAGE 'plpgsql'
	
	COST 100
	VOLATILE

AS $BODY$

declare
	nroFrame integer;
begin
	insert into traza(nro_disk_page) values(nro_pag);
	nroFrame = get_fr_by_page(nro_pag);
 	if(nroFrame = 0) then
		nroFrame = get_pag_from_disk(nro_pag);
	else
	   	RAISE NOTICE 'Acceso a BufferPool Pag:%, Frame:%',nro_pag, nroFrame;
	end if;
	
    return nroFrame;
end;
	
$BODY$;

ALTER FUNCTION public.get_disk_page(nro_pag integer)
    OWNER TO postgres;
-----------------------
							  
CREATE OR REPLACE FUNCTION public.get_disk_page_LRU(nro_pag integer)
	RETURNS integer
	LANGUAGE 'plpgsql'
	
	COST 100
	VOLATILE

AS $BODY$

declare
	nroFrame integer;
begin
	insert into traza(nro_disk_page) values(nro_pag);
	nroFrame = get_fr_by_page(nro_pag);
 	if(nroFrame = 0) then
		nroFrame = get_pag_from_disk_LRU(nro_pag);
	else
	   	RAISE NOTICE 'Acceso a BufferPool Pag:%, Frame:%',nro_pag, nroFrame;
	end if;
	
    return nroFrame;
end;
	
$BODY$;

ALTER FUNCTION public.get_disk_page_LRU(nro_pag integer)
    OWNER TO postgres;
-----------------------
CREATE OR REPLACE FUNCTION public.get_disk_page_MRU(nro_pag integer)
	RETURNS integer
	LANGUAGE 'plpgsql'
	
	COST 100
	VOLATILE

AS $BODY$

declare
	nroFrame integer;
begin
	insert into traza(nro_disk_page) values(nro_pag);
	nroFrame = get_fr_by_page(nro_pag);
 	if(nroFrame = 0) then
		nroFrame = get_pag_from_disk_MRU(nro_pag);
	else
	   	RAISE NOTICE 'Acceso a BufferPool Pag:%, Frame:%',nro_pag, nroFrame;
	end if;
	
    return nroFrame;
end;
	
$BODY$;

ALTER FUNCTION public.get_disk_page_MRU(nro_pag integer)
    OWNER TO postgres;
-----------------------

CREATE OR REPLACE FUNCTION public.get_fr_by_page(nro_pag integer)
	RETURNS integer
	LANGUAGE 'plpgsql'
	
	COST 100
	VOLATILE

AS $BODY$

declare
	frame integer;
begin
	select nro_frame into frame from bufferpool where nro_disk_page = nro_pag;
	if not found then
		frame = 0;
	else
		update bufferpool set last_touch = clock_timestamp() where nro_disk_page = nro_pag;
	end if;
	return frame;
end;
	
$BODY$;

ALTER FUNCTION public.get_fr_by_page(nro_pag integer)
    OWNER TO postgres;
------------------
CREATE OR REPLACE FUNCTION public.get_pag_from_disk(nro_pag integer)
	RETURNS integer
	LANGUAGE 'plpgsql'
	
	COST 100
	VOLATILE

AS $BODY$

declare
	fr integer;
begin
	fr = get_free_frame(nro_pag);
	--read_pag_from_disk(fr,nro_pag);
	update bufferpool set pfree='false', dirty='false', nro_disk_page=nro_pag, last_touch=clock_timestamp()
	where nro_frame=fr;
	return fr;
	
end;
	
$BODY$;

ALTER FUNCTION public.get_pag_from_disk(nro_pag integer)
    OWNER TO postgres;
---------------
							  
CREATE OR REPLACE FUNCTION public.get_pag_from_disk_LRU(nro_pag integer)
	RETURNS integer
	LANGUAGE 'plpgsql'
	
	COST 100
	VOLATILE

AS $BODY$

declare
	fr integer;
begin
	fr = get_free_frame_LRU(nro_pag);
	--read_pag_from_disk(fr,nro_pag);
	update bufferpool set pfree='false', dirty='false', nro_disk_page=nro_pag, last_touch=clock_timestamp()
	where nro_frame=fr;
	return fr;
	
end;
	
$BODY$;

ALTER FUNCTION public.get_pag_from_disk_LRU(nro_pag integer)
    OWNER TO postgres;
---------------
CREATE OR REPLACE FUNCTION public.get_pag_from_disk_MRU(nro_pag integer)
	RETURNS integer
	LANGUAGE 'plpgsql'
	
	COST 100
	VOLATILE

AS $BODY$

declare
	fr integer;
begin
	fr = get_free_frame_MRU(nro_pag);
	--read_pag_from_disk(fr,nro_pag);
	update bufferpool set pfree='false', dirty='false', nro_disk_page=nro_pag, last_touch=clock_timestamp()
	where nro_frame=fr;
	return fr;
	
end;
	
$BODY$;

ALTER FUNCTION public.get_pag_from_disk_MRU(nro_pag integer)
    OWNER TO postgres;
---------------

							  
CREATE OR REPLACE FUNCTION public.read_pag_from_disk(fr integer,nro_pag integer)
	RETURNS void
	LANGUAGE 'plpgsql'
	COST 100
	VOLATILE
AS $BODY$
declare
	nroFr integer;
begin
end;	
$BODY$;
ALTER FUNCTION public.read_pag_from_disk(fr integer, nro_pag integer)
    OWNER TO postgres;

----------------
CREATE OR REPLACE FUNCTION public.get_free_frame(nro_pag integer)
	RETURNS integer
	LANGUAGE 'plpgsql'
	COST 100
	VOLATILE
AS $BODY$
declare
	fr registro_desalojo%rowtype;
begin
	select b.nro_frame into fr from bufferpool b where pfree='true'
	order by nro_frame limit 1;
	if not found then
		--fr = pick_frame_LRU();
		--fr = pick_frame_MRU();
		fr = pick_frame_139();
		RAISE NOTICE 'Acceso a disco con reemplazo. Pag: %, Frame: %, Des: %', nro_pag, fr.frame, fr.valorDesalojado;
	else
		RAISE NOTICE 'Acceso a disco sin reemplazo. Pag: %, Frame: %', nro_pag, fr.frame;
	end if;
	return fr.frame;
end;	
$BODY$;
ALTER FUNCTION public.get_free_frame(nro_pag integer)
    OWNER TO postgres;
----------------------
							  
CREATE OR REPLACE FUNCTION public.get_free_frame_LRU(nro_pag integer)
	RETURNS integer
	LANGUAGE 'plpgsql'
	COST 100
	VOLATILE
AS $BODY$
declare
	fr registro_desalojo%rowtype;
begin
	select b.nro_frame into fr from bufferpool b where pfree='true'
	order by nro_frame limit 1;
	if not found then
		fr = pick_frame_LRU();
		RAISE NOTICE 'Acceso a disco con reemplazo. Pag: %, Frame: %, Des: %', nro_pag, fr.frame, fr.valorDesalojado;
	else
		RAISE NOTICE 'Acceso a disco sin reemplazo. Pag: %, Frame: %', nro_pag, fr.frame;
	end if;
	return fr.frame;
end;	
$BODY$;
ALTER FUNCTION public.get_free_frame_LRU(nro_pag integer)
    OWNER TO postgres;
-----------------
CREATE OR REPLACE FUNCTION public.get_free_frame_MRU(nro_pag integer)
	RETURNS integer
	LANGUAGE 'plpgsql'
	COST 100
	VOLATILE
AS $BODY$
declare
	fr registro_desalojo%rowtype;
begin
	select b.nro_frame into fr from bufferpool b where pfree='true'
	order by nro_frame limit 1;
	if not found then
		fr = pick_frame_MRU();
		RAISE NOTICE 'Acceso a disco con reemplazo. Pag: %, Frame: %, Des: %', nro_pag, fr.frame, fr.valorDesalojado;
	else
		RAISE NOTICE 'Acceso a disco sin reemplazo. Pag: %, Frame: %', nro_pag, fr.frame;
	end if;
	return fr.frame;
end;	
$BODY$;
ALTER FUNCTION public.get_free_frame_MRU(nro_pag integer)
    OWNER TO postgres;



--------------
Drop function public.pick_frame_LRU();
CREATE OR REPLACE FUNCTION public.pick_frame_LRU()
	RETURNS registro_desalojo
	LANGUAGE 'plpgsql'
	
	COST 100
	VOLATILE

AS $BODY$

declare
	nroFrame registro_desalojo%rowtype;
begin
	select nro_disk_page into nroFrame.valorDesalojado from bufferpool
	where last_touch = (select min (last_touch) 
	from bufferpool) limit 1;
		
	select nro_frame into nroFrame.frame from bufferpool 
	where last_touch = (select min (last_touch) 
	from bufferpool) limit 1;
							  
	return nroFrame;
end;
	
$BODY$;

ALTER FUNCTION public.pick_frame_LRU()
    OWNER TO postgres;

------------------------------
CREATE OR REPLACE FUNCTION public.pick_frame_MRU()
	RETURNS registro_desalojo
	LANGUAGE 'plpgsql'
	
	COST 100
	VOLATILE

AS $BODY$

declare
	nroFrame registro_desalojo%rowtype;
begin
	select nro_disk_page into nroFrame.valorDesalojado from bufferpool 
	where last_touch = (select max (last_touch) 
	from bufferpool) limit 1;
							  
	select nro_frame into nroFrame.frame from bufferpool 
	where last_touch = (select max (last_touch)
	from bufferpool) limit 1;
	
	return nroFrame;
end;
	
$BODY$;

ALTER FUNCTION public.pick_frame_MRU()
    OWNER TO postgres;
							  
-------------------		  
CREATE OR REPLACE FUNCTION public.pick_frame_139()
	RETURNS registro_desalojo
	LANGUAGE 'plpgsql'
	
	COST 100
	VOLATILE

AS $BODY$

declare
	nroFrame registro_desalojo%rowtype;
begin
	if(solicitudesSecuenciales())then
		nroFrame = pick_frame_MRU();
	   	drop table if exists traza;
		Create table if not exists traza(tiempo serial, nro_disk_page int);
	
	    --- reset de la secuencia
	else
		nroFrame = pick_frame_LRU();
	end if;							  
	return nroFrame;
end;
	
$BODY$;

ALTER FUNCTION public.pick_frame_139()
    OWNER TO postgres;
---------------------------
select solicitudesSecuenciales();
	   
CREATE OR REPLACE FUNCTION public.solicitudesSecuenciales()
	RETURNS boolean
	LANGUAGE 'plpgsql'
	
	COST 100
	VOLATILE

AS $BODY$

declare
	r traza%rowtype;
	nroFrame integer;
	cantidad integer;
	valorPag integer=-1;
begin
	select count(nro_disk_page) into cantidad from traza;
	
	FOR r IN SELECT * FROM traza WHERE tiempo > cantidad/2 LOOP
	   if(valorPag = -1)then
	   		valorPag = r.nro_disk_page;
	   		valorPag:= valorPag +1;
	   elsif(valorPag = r.nro_disk_page) then
	   		valorPag := valorPag +1;
	   else
	   		return false;
	   end if;
	   
	   end loop;
	
	return true;
end;
	
$BODY$;

ALTER FUNCTION public.solicitudesSecuenciales()
    OWNER TO postgres;
-------------
CREATE OR REPLACE FUNCTION public.print(texto varchar)
	RETURNS void
	LANGUAGE 'plpgsql'
	
	COST 100
	VOLATILE

AS $BODY$

declare
	
begin
	RAISE NOTICE '%', texto;
end;
	
$BODY$;

ALTER FUNCTION public.print(texto varchar)
    OWNER TO postgres;
	   
	   