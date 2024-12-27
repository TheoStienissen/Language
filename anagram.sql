create or replace function f_anagram (p_woord in varchar2) return varchar2
is
l_woord   varchar2(100) := lower(trim(p_woord));
l_result varchar2(100);
begin
  select listagg(word, '') within group (order by word) into l_result from (select substr(l_woord, level, 1) word from dual connect by level <= nvl(length(l_woord), 0));
  return l_result;
end;
/

create or replace function f_contains (p_word_small in varchar2, p_word_large in varchar2, p_lower in boolean default true)
return number
is
l_match      number(1)     := 1;
l_rest       varchar2(100) := p_word_large;
l_word_small varchar2(100);
l_dummy      number(3);
begin
if p_lower then l_word_small := lower(p_word_small); else l_word_small := p_word_small; end if;
	
if l_word_small is null or p_word_large is null then return null;
elsif length(l_word_small) >  length(p_word_large)
then
  return 0;
else
  <<test_done>>
  for j in 1 .. length(l_word_small)
  loop
   l_dummy := instr(l_rest, substr(l_word_small, j, 1));
   if l_dummy = 0
   then
     l_match := 0;
     exit test_done;
   else
    l_rest := substr(l_rest, 1, l_dummy - 1) || substr(l_rest, l_dummy + 1);
  end if;
  end loop;
  return l_match;
end if;
end;
/

