delete from traza;
delete from bufferpool;
insert into bufferpool values(1,true,false,1,clock_timestamp());
insert into bufferpool values(2,true,false,2,clock_timestamp());
insert into bufferpool values(3,true,false,3,clock_timestamp());
insert into bufferpool values(4,true,false,4,clock_timestamp());

select print('Traza con 139:');
select get_disk_page(20);
select get_disk_page(21);
select get_disk_page(22);
select get_disk_page(23);
select get_disk_page(24);
select get_disk_page(23);
select get_disk_page(24);

delete from traza;
delete from bufferpool;
insert into bufferpool values(1,true,false,1,clock_timestamp());
insert into bufferpool values(2,true,false,2,clock_timestamp());
insert into bufferpool values(3,true,false,3,clock_timestamp());
insert into bufferpool values(4,true,false,4,clock_timestamp());

select print('Traza con LRU:');							  
select get_disk_page_LRU(20);
select get_disk_page_LRU(21);
select get_disk_page_LRU(22);
select get_disk_page_LRU(23);
select get_disk_page_LRU(24);
select get_disk_page_LRU(23);
select get_disk_page_LRU(24);

delete from traza;
delete from bufferpool;
insert into bufferpool values(1,true,false,1,clock_timestamp());
insert into bufferpool values(2,true,false,2,clock_timestamp());
insert into bufferpool values(3,true,false,3,clock_timestamp());
insert into bufferpool values(4,true,false,4,clock_timestamp());
							
select print('Traza con MRU:');
select get_disk_page_MRU(20);
select get_disk_page_MRU(21);
select get_disk_page_MRU(22);
select get_disk_page_MRU(23);
select get_disk_page_MRU(24);
select get_disk_page_MRU(23);
select get_disk_page_MRU(24);
