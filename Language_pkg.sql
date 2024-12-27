/*************************************************************************************************************************************************

Name        : Language.sql
Last update : December 2024
Author      : Theo stienissen
E-mail      : theo.stienissen@gmail.com
@C:\Users\Theo\OneDrive\Theo\Project\Language\Language_pkg.sql

*************************************************************************************************************************************************/


drop  package language_pkg;
drop  type word_row;
drop  type word_ty;

create type word_ty as object
( word    varchar2(100)
, anagram varchar2(100));
/

create type word_row as table of word_ty;
/

create or replace package language_pkg
is
function anagram (p_woord in varchar2) return varchar2;

function anagram_to_word (in_anagram in varchar2) return sys.odcivarchar2list pipelined;

function checkword (in_string in varchar2) return boolean;

function checkwordupper (in_string in varchar2) return boolean;

function checkwordx (in_string in varchar2) return boolean;

function diff_chars (in_word in varchar2) return boolean;

function diff_chars2 (p_word in varchar2) return integer;

function f_anagram (in_woord in varchar2) return varchar2;

function f_consonants_tot (in_word in varchar2) return integer;

function f_consonants2_tot (in_word in varchar2) return integer;

function f_tot_characters (in_word in varchar2) return integer;

function f_vowels_tot (in_word in varchar2) return integer;

function increasing_chars_ge (in_word in varchar2) return boolean;

function increasing_chars_gt (in_word in varchar2) return boolean;

function increasing_chars_le (in_word in varchar2) return boolean;

function increasing_chars_lt (in_word in varchar2) return boolean;

function not_used  (in_source in varchar2, in_target in varchar2) return varchar2;

function sentence (in_word in varchar2) return varchar2;

function ltrimword (in_string in varchar2) return varchar2;

function rtrimword (in_string in varchar2) return varchar2;

function trimword (p_string in varchar2) return varchar2;

function shift_word (in_word in varchar2, in_offset in number) return varchar2;

function word_in (in_source in varchar2, in_target in varchar2) return boolean;

function word_in2 (in_source in varchar2, in_target in varchar2) return integer;

procedure add_word (p_string in varchar2);

function f_tot_characters (p_word in varchar2) return integer;

function reverse (p_word in varchar2) return varchar2;
end language_pkg;
/





create or replace package body language_pkg
is

function anagram (p_woord in varchar2) return varchar2
is
l_woord   varchar2(100) := lower(trim(p_woord));
l_result varchar2(100);
begin
  select listagg(word, '') within group (order by word) into l_result from (select substr (l_woord, level, 1) word from dual connect by level <= nvl(length(l_woord), 0));
  return l_result;

exception when others
then
  util.show_error ('Error raised from function anagram for: ' || p_woord, sqlerrm);
  return null;
end anagram;

/******************************************************************************************************************************************************************/

--
-- Find all words which have this anagram
--
function anagram_to_word (in_anagram in varchar2) return sys.odcivarchar2list pipelined
is
l_text varchar2 (32767);
begin
  for w in (select woord from theo.woordenboek where anagram (woord) = in_anagram)
  loop
    pipe row (w.woord);
  end loop;

exception when others
then
  util.show_error ('Error raised from function anagram_to_word for anagram: ' || in_anagram, sqlerrm);
end anagram_to_word;

/******************************************************************************************************************************************************************/

--
-- Check if the entered text consists of alphanumeric characters
--
function checkword (in_string in varchar2) return boolean
is
l_is_string boolean;
l_length  number (5) := length (in_string);
begin
  if in_string is null then l_is_string := false;
  else
  <<nok>>
  for j in 1 .. l_length
  loop
    l_is_string := substr (in_string, j, 1) between 'a' and 'z';
    exit nok when not l_is_string;
  end loop;
  end if;
  return l_is_string;

exception when others
then
  util.show_error ('Error raised from function checkword.', sqlerrm);
  return null;
end;

/******************************************************************************************************************************************************************/

--
-- Check is a word consists of alphanumeric uppercase or lowercase characters
--
function checkwordupper (in_string in varchar2) return boolean
is
l_is_string boolean;
l_length  number (5) := length (in_string);
begin
  if in_string is null then return null;
  else
  <<nok>>
  for j in 1 .. l_length
  loop
    l_is_string := upper (substr (in_string, j, 1)) between 'A' and 'Z' or instr (' -.', substr (in_string, j, 1)) = 0;
    exit nok when not l_is_string;
  end loop;
  end if;
  return l_is_string;

exception when others
then
  util.show_error ('Error raised from function checkwordupper.', sqlerrm);
  return null;
end;

/******************************************************************************************************************************************************************/

--
-- alphanumeric or . - 
--
function checkwordx (in_string in varchar2) return boolean
is
l_is_string boolean;
begin
  if in_string is null then return false;
  else
  <<nok>>
  for j in 1 .. length (in_string)
  loop
    l_is_string := substr (in_string, j, 1) between 'a' and 'z' or instr ('.-''', substr (in_string, j, 1)) != 0;
    exit nok when not l_is_string;
  end loop;
  end if;
  return l_is_string;

exception when others
then
  util.show_error ('Error raised from function checkwordx.', sqlerrm);
  return null;
end;

/******************************************************************************************************************************************************************/

--
--
--
function diff_chars (in_word in varchar2) return boolean
is
l_different boolean;
l_length number (2) := length (in_word);
begin
  if l_length <= 1
  then return true;
  else
    <<done>>
    for j in 2 .. l_length
    loop
      l_different := instr (substr (in_word, 1, j - 1), substr (in_word, j , 1)) = 0;
      exit done when not l_different;
    end loop;
    return l_different;
  end if;

exception when others
then
  util.show_error ('Error raised from function diff_chars for: ' || in_word, sqlerrm);
  return null;
end diff_chars;

/*************************************************************************************************************************************************/

--
-- Function returns 1 if all characters in a word are different else it returns 0.
--
function diff_chars2 (p_word in varchar2) return integer
is
l_different boolean;
l_string    varchar2 (100) := upper(p_word);
l_length    integer (2)    := length (p_word);
begin
    select listagg (distinct word, '') within group (order by word) into l_string
  from (select substr (l_string, level, 1) word from dual connect by level <= nvl(length (l_string), 0));
    if length (l_string)  = length (p_word) or p_word is null then return 1; else return 0; end if;

exception when others
then
  util.show_error ('Error raised from function diff_chars2 for: ' || p_word, sqlerrm);
  return null;
end diff_chars2;

/******************************************************************************************************************************************************************/

--
-- Save information about the entered word
--
function f_anagram (in_woord in varchar2) return varchar2
is
l_woord  varchar2 (100) := lower (trim (in_woord));
l_result varchar2 (100) := '';
begin
  select listagg (word, ', ') within group (order by word) into l_result from (select substr (l_woord, level, 1) word from dual connect by level <= nvl (length (l_woord), 0));
  return l_result;

exception when others
then
  util.show_error ('Error raised from function f_anagram', sqlerrm);
  return null;
end;

/******************************************************************************************************************************************************************/

--
-- Total number of consonants
--
function f_consonants_tot (in_word in varchar2) return integer
is
l_count  number (2) := 0;
begin
  for j in 1 .. length (in_word)
  loop
    if instr ('BCDFGHJKLMNPQRSTVWXYZ', substr (in_word, j , 1)) > 0
    then
      l_count := l_count + 1;
    end if;
  end loop;
  return l_count;

exception when others
then
  util.show_error ('Error raised from function f_consonants_tot.', sqlerrm);
  return null;
end f_consonants_tot;

/******************************************************************************************************************************************************************/

--
-- Total number of consonants
--
function f_consonants2_tot (in_word in varchar2) return integer
is
begin
  return length (replace (in_word, ' ')) - f_vowels_tot (in_word);

exception when others
then
  util.show_error ('Error raised from function f_consonants2_tot.', sqlerrm);
  return null;
end f_consonants2_tot;

/******************************************************************************************************************************************************************/

--
-- Total number of different characters
--
function f_tot_characters (in_word in varchar2) return integer
is
l_length number (2) := length (in_word);
l_count  number (2) := 1;
l_string varchar2 (100);
l_word   varchar2 (100) := upper (in_word);
begin
  if in_word is null
  then return 0;
  elsif l_length = 1 then return 1;
  else
  l_string := substr (l_word, 1, 1);
  for j in 2 .. l_length
  loop
    if instr (l_string, substr (l_word, j, 1)) = 0
    then
      l_string := l_string || substr (l_word, j, 1);
      l_count  := l_count + 1;
    end if;
  end loop;
  end if;
  return l_count;

exception when others
then
  util.show_error ('Error raised from function f_tot_characters.', sqlerrm);
  return null;
end f_tot_characters;

/******************************************************************************************************************************************************************/

--
-- Total number of vowels
--
function f_vowels_tot (in_word in varchar2) return integer
is
l_count  number (2) := 0;
l_word   varchar2 (100) := upper (in_word);
begin
  for j in 1 .. length (in_word)
  loop
    if instr ('AEIOU', substr (in_word, j , 1)) > 0
    then
      l_count := l_count + 1;
    end if;
  end loop;
  return l_count;

exception when others
then
  util.show_error ('Error raised from function f_vowels_tot.', sqlerrm);
  return null;
end f_vowels_tot;

/******************************************************************************************************************************************************************/

--
--  Are the characters in ascending order or equal
--
function increasing_chars_ge (in_word in varchar2) return boolean
is
begin
  if length (in_word) <= 1 then return true;
  elsif length (in_word) = 2
  then return substr (in_word, 1, 1) <= substr (in_word, 2, 1);
  else return increasing_chars_ge (substr (in_word, 1, 2)) and increasing_chars_ge (substr (in_word, 2));
  end if;

exception when others
then
  util.show_error ('Error raised from function increasing_chars_ge', sqlerrm);
  return null;
end increasing_chars_ge;

/******************************************************************************************************************************************************************/

--
--  Are the characters in ascending order
--
function increasing_chars_gt (in_word in varchar2) return boolean
is
begin
  if length (in_word) <= 1 then return true;
  elsif length (in_word) = 2
  then return substr (in_word, 1, 1) < substr (in_word, 2, 1);
  else return increasing_chars_gt (substr (in_word, 1, 2)) and increasing_chars_gt (substr (in_word, 2));
  end if;

exception when others
then
  util.show_error ('Error raised from function increasing_chars_gt', sqlerrm);
  return null;
end increasing_chars_gt;

/******************************************************************************************************************************************************************/

--
--  Are the characters in descending order  or equal
--
function increasing_chars_le (in_word in varchar2) return boolean
is
begin
  if length (in_word) <= 1 then return true;
  elsif length (in_word) = 2
  then return substr (in_word, 1, 1) >= substr (in_word, 2, 1);
  else return increasing_chars_le (substr (in_word, 1, 2)) and increasing_chars_le (substr (in_word, 2));
  end if;

exception when others
then
  util.show_error ('Error raised from function increasing_chars_le', sqlerrm);
  return null;
end increasing_chars_le;

/******************************************************************************************************************************************************************/

--
-- Are the characters in descending order
--
function increasing_chars_lt (in_word in varchar2) return boolean
is
begin
  if length (in_word) <= 1 then return true;
  elsif length (in_word) = 2
  then return substr (in_word, 1, 1) > substr (in_word, 2, 1);
  else return increasing_chars_lt (substr (in_word, 1, 2)) and increasing_chars_lt (substr (in_word, 2));
  end if;

exception when others
then
  util.show_error ('Error raised from function increasing_chars_lt', sqlerrm);
  return null;
end increasing_chars_lt;

/******************************************************************************************************************************************************************/

--
-- Returns the characters that are not used
--
function not_used (in_source in varchar2, in_target in varchar2) return varchar2
is
l_target    varchar2 (100) := in_target;
l_position  integer (2);
begin
  for j in 1 .. length (in_source)
  loop
    l_position := instr (l_target, substr (in_source, j, 1));
    if l_position != 0
    then
      l_target := substr (l_target, 1, l_position - 1) || substr (l_target, l_position + 1);
    end if;
  end loop;
  return f_anagram (l_target);

exception when others
then
  util.show_error ('Error raised from function not_used', sqlerrm);
  return null;
end not_used;

/******************************************************************************************************************************************************************/

--
-- Try to find all words that can be made from the characters entered.
--
function sentence (in_word in varchar2) return varchar2
is
begin
  if in_word is null
  then return '';
  else
  for j in (select woord, not_used (woord, in_word) not_used from woordenboek where word_in2 (woord, in_word) = 1)
  loop
    return j.woord || ' ' || sentence (j.not_used);
  end loop;
  end if;

exception when others
then
  util.show_error ('Error raised from function sentence', sqlerrm);
  return null;
end sentence;

/******************************************************************************************************************************************************************/

--
-- Removes all non-alpha characters from the beginning of a word.
--
function ltrimword (in_string in varchar2) return varchar2
is
l_string varchar2 (1000) := in_string;
begin
  while substr (l_string, 1, 1) not between 'a' and 'z' and substr (l_string, 1, 1) not between 'A' and 'Z'
  loop
    l_string := substr (l_string, 2);
  end loop;
  return l_string;

exception when others
then
  util.show_error ('Error raised from function ltrimwoord.', sqlerrm);
  return null;
end;

/******************************************************************************************************************************************************************/

--
-- Removes all non-alpha charcters from the end of a string.
--
function rtrimword (in_string in varchar2) return varchar2
is
l_string varchar2 (1000) := lower (in_string);
begin
  while substr (l_string, -1) not between 'a' and 'z' and substr (l_string, 1, 1) not between 'A' and 'Z'
  loop
    l_string := substr (l_string, 1, length (l_string) - 1);
  end loop;
  return l_string;

exception when others
then
  util.show_error ('Error raised from function rtrimwoord.', sqlerrm);
  return null;
end;

/*************************************************************************************************************************************************/

--
-- Trim function
--
function trimword (p_string in varchar2) return varchar2
is
begin
  return ltrimword (rtrimword (p_string));

exception when others
then
  util.show_error ('Error raised from function trimwoord for: ' || p_string, sqlerrm);
  return null;
end trimword;

/******************************************************************************************************************************************************************/

--
-- Alphabetical shift of "in_offset" characters. Roman encryption.
--
function shift_word (in_word in varchar2, in_offset in number) return varchar2
is
l_offset number (5);
l_result varchar2 (100) := '';
begin
  for j in 1 .. length (in_word)
  loop
    l_offset := mod (ascii (substr (in_word, j , 1)) - ascii ('A') + in_offset, 26);
    if l_offset < 0 then l_offset := l_offset + 26; end if;
    l_result := l_result || chr (l_offset +  ascii ('A'));
  end loop;
  return l_result;

exception when others
then
  util.show_error ('Error raised from function shift_word', sqlerrm);
  return null;
end shift_word;

/******************************************************************************************************************************************************************/

--
-- Checks if all characters of the word are available in the target
--
function word_in (in_source in varchar2, in_target in varchar2) return boolean
is
l_target    varchar2 (100) := in_target;
l_match     boolean;
l_position  integer(2);
begin
  if length (in_source) > length (in_target)
  then
    l_match := false;
  else
    <<not_found>>
    for j in 1 .. length (in_source)
    loop
      l_position := instr (l_target, substr (in_source, j, 1));
      l_match := l_position != 0;
      exit not_found when not l_match;
      l_target := substr (l_target, 1, l_position - 1) || substr (l_target, l_position + 1);
    end loop;
  end if;
  return l_match;

exception when others
then
  util.show_error ('Error raised from function word_in for source: ' || in_source || ' and target: ' || in_target, sqlerrm);
  return null;
end word_in;

/******************************************************************************************************************************************************************/

--
-- Checks if all characters of the word are available in the target
--
function word_in2 (in_source in varchar2, in_target in varchar2) return integer
is
begin
  if word_in (in_source, in_target)
  then return 1;
  else return 0;
  end if;

exception when others
then
  util.show_error ('Error raised from 2-nd function word_in for source: ' || in_source || ' and target: ' || in_target, sqlerrm);
  return null;
end word_in2;

/******************************************************************************************************************************************************************/

--
-- Procedure tries to add a word to the dictionary. If the word already exists, it does nothing.
--
procedure add_word (p_string in varchar2)
is
begin
  if p_string is not null
  then
    insert into vandale_final values ( upper (p_string));
  end if;

exception when dup_val_on_index then null;
          when others
then
  util.show_error ('Error raised from procedure add_word for: ' || p_string, sqlerrm);
end add_word;

/*************************************************************************************************************************************************/

--
-- Function returns the total number of different characters in a word..
--
function f_tot_characters (p_word in varchar2) return integer
is
l_word   varchar2(100) := upper (p_word);
begin
  select distinct substr (l_word, level, 1) into l_word from dual connect by level <= nvl (length (l_word), 0);
  return length (l_word);

exception when others
then
  util.show_error ('Error raised from function f_tot_characters for: ' || p_word, sqlerrm);
  return null;
end f_tot_characters;

/*************************************************************************************************************************************************/

function reverse (p_word in varchar2) return varchar2
is
l_return   varchar2 (400);
begin
  select reverse (p_word) into l_return from dual;
  return l_return;

exception when others
then
  util.show_error ('Error raised from function reverse for: ' || p_word, sqlerrm);
  return null;
end reverse;
end language_pkg;
/


