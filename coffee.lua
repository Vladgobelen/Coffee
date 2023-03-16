#! /bin/env lua
print ("fdsa");
local signal_file_name = '.coffee'
local signal_file = os.getenv('HOME')..'/'..signal_file_name;
local file = io.open(signal_file);

if(file) then
    local stat = file:read('*all');
    file:close();
    if stat == 'working' then
       file = io.open(signal_file,'w');
       file:write('stop');
       return 0;
    else
       file = io.open(signal_file,'w');
       file:write('working');
       file:close();
       stat="working";
    end
    local timer = 430;
    -- получаум ID прогессбара
    local qpopen = io.popen('kdialog --progressbar "Кофе" '..timer..' ',"r");
    local qprogress_id    = qpopen:read("*l");
    local play_sound = true;
    -- теперь мы крутим цикл не вечно, но оставляем его
    while(stat=="working") do
            -- заводим цикл отправки сообщений прогрессбару
            for coffee=0, timer ,1 do
                -- теперь проверяем стастус в цикле 
                -- отправки счётчика прогрессбару
                file = io.open(signal_file,'r');
                stat = file:read('*all');
                file:close();
                -- если повторно нажать хоткей
                -- значением поменяется на стоп
                -- выходим из цикла прогрессбара
                -- и задаём оснанов для основного цикла
                if stat == "stop" then 
                    play_sound=false; 
                    stat="stop"
                    break; 
                end
                --шлём счётчик прогрессбару
                local qdbus = 'qdbus '..qprogress_id..' Set "" value '..tostring(coffee)..' >/dev/null';
                os.execute(qdbus);
                os.execute("sleep 1")
            end
            -- проигрываем музыку тогда и только тогда когда завешилось естественно
            -- если прервали играть не надо ибо зачем, а главное ****я
            if play_sound == true then 
               -- если музыка не просто тилинь тилинь короткая, а целая песня 
               -- то будет играть до победного и только тогда всё завершится корректно
               -- если тут музыка длинная то надо делать детекст нажатия в окне
               -- прогресс бара кнопочки "закрыть" и в фоне грохать музыку
               -- для этого уже надо завести отдельный поток который будет это делать
               -- музыка просто тилинь-тилинь недолгая
               os.execute("mpv --force-window=no /home/diver/Загрузки/Музыка/12/coffee.mp3");
               os.execute("killall kdialog_progress_helper");
               file = io.open(signal_file,'w');
               file:write('stop');
               file:close();
               break;
            end
            -- всегда грохаем прогресс бар после достижения таймером финала
            os.execute("qdbus "..qprogress_id.." org.kde.kdialog.ProgressDialog.close");
            -- после того как в любом случае завершился прогресс бар 
            -- посылаем сигнал сами себе что мы всё. 
            file = io.open(signal_file,'w');
            file:write('stop');
        end
    end
