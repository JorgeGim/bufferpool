Create table bufferpool(nro_frame int,
pfree boolean,
dirty boolean,
nro_disk_page int,
last_touch timestamp);

insert into bufferpool values(1,true,false,1,clock_timestamp());
insert into bufferpool values(2,true,false,2,clock_timestamp());
insert into bufferpool values(3,true,false,3,clock_timestamp());
insert into bufferpool values(4,true,false,4,clock_timestamp());

select * from bufferpool;

select get_disk_page(112);

CREATE OR REPLACE FUNCTION public.get_disk_page(nro_pag integer)
	RETURNS integer
	LANGUAGE 'plpgsql'
	
	COST 100
	VOLATILE

AS $BODY$

declare
	nroFrame integer;
begin
	nroFrame = get_fr_by_page(nro_pag);
 	if(nroFrame = 0) then
		nroFrame = get_pag_from_disk(nro_pag);
	else
		--reiseNotice "",b;
	end if;
    return nroFrame;
end;
	
$BODY$;

ALTER FUNCTION public.get_disk_page(nro_pag integer)
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
	fr = get_free_frame();
	--read_pag_from_disk(fr,nro_pag);
	update bufferpool set pfree='false', dirty='false', nro_disk_page=nro_pag, last_touch=clock_timestamp()
	where nro_frame=fr;
	return fr;
	
end;
	
$BODY$;

ALTER FUNCTION public.get_pag_from_disk(nro_pag integer)
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
CREATE OR REPLACE FUNCTION public.get_free_frame()
	RETURNS integer
	LANGUAGE 'plpgsql'
	COST 100
	VOLATILE
AS $BODY$
declare
	fr integer;
begin
	select b.nro_frame into fr from bufferpool b where pfree='true'
	order by nro_frame limit 1;
	if not found then
		--fr = pick_frame_LRU();
		fr = pick_frame_MRU();
		-- raise notice 2
	else
	-- raise notice 3
	end if;
	return fr;
end;	
$BODY$;
ALTER FUNCTION public.get_free_frame()
    OWNER TO postgres;



--------------
CREATE OR REPLACE FUNCTION public.pick_frame_LRU()
	RETURNS integer
	LANGUAGE 'plpgsql'
	
	COST 100
	VOLATILE

AS $BODY$

declare
	nroFrame integer;
begin
	select nro_frame into nroFrame from bufferpool where last_touch = (select min (last_touch) from bufferpool)
	limit 1;
	return nroFrame;
end;
	
$BODY$;

ALTER FUNCTION public.pick_frame_LRU()
    OWNER TO postgres;

------------------------------
CREATE OR REPLACE FUNCTION public.pick_frame_MRU()
	RETURNS integer
	LANGUAGE 'plpgsql'
	
	COST 100
	VOLATILE

AS $BODY$

declare
	nroFrame integer;
begin
	select nro_frame into nroFrame from bufferpool where last_touch = (select max (last_touch) from bufferpool)
	limit 1;
	return nroFrame;
end;
	
$BODY$;

ALTER FUNCTION public.pick_frame_MRU()
    OWNER TO postgres;
							  
							  
