delete from traza;
delete from bufferpool;
insert into bufferpool values(1,true,false,1,clock_timestamp());
insert into bufferpool values(2,true,false,2,clock_timestamp());
insert into bufferpool values(3,true,false,3,clock_timestamp());
insert into bufferpool values(4,true,false,4,clock_timestamp());

select print('Traza con 139:');
							select get_disk_page(10);
							select get_disk_page(11);
							select get_disk_page(13);-- mru  
							select get_disk_page(12);
							select get_disk_page(20);
							select get_disk_page(1);-- mru
							select get_disk_page(10);
							select get_disk_page(11);
							select get_disk_page(13);
							select get_disk_page(12);
							select get_disk_page(10);
							select get_disk_page(11);

							  
delete from traza;
delete from bufferpool;
insert into bufferpool values(1,true,false,1,clock_timestamp());
insert into bufferpool values(2,true,false,2,clock_timestamp());
insert into bufferpool values(3,true,false,3,clock_timestamp());
insert into bufferpool values(4,true,false,4,clock_timestamp());

select print('Traza con MRU:');
							select get_disk_page_MRU(10);
							select get_disk_page_MRU(11);
							select get_disk_page_MRU(13);-- mru  
							select get_disk_page_MRU(12);
							select get_disk_page_MRU(20);
							select get_disk_page_MRU(1);-- mru
							select get_disk_page_MRU(10);
							select get_disk_page_MRU(11);
							select get_disk_page_MRU(13);
							select get_disk_page_MRU(12);
							select get_disk_page_MRU(10);
							select get_disk_page_MRU(11);  
							  
							  
delete from traza;
delete from bufferpool;
insert into bufferpool values(1,true,false,1,clock_timestamp());
insert into bufferpool values(2,true,false,2,clock_timestamp());
insert into bufferpool values(3,true,false,3,clock_timestamp());
insert into bufferpool values(4,true,false,4,clock_timestamp());

select print('Traza con LRU:');
							select get_disk_page_LRU(10);
							select get_disk_page_LRU(11);
							select get_disk_page_LRU(13);-- mru  
							select get_disk_page_LRU(12);
							select get_disk_page_LRU(20);
							select get_disk_page_LRU(1);-- mru
							select get_disk_page_LRU(10);
							select get_disk_page_LRU(11);
							select get_disk_page_LRU(13);
							select get_disk_page_LRU(12);
							select get_disk_page_LRU(10);
							select get_disk_page_LRU(11);  

