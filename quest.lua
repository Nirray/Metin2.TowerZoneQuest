quest deviltower_zone begin
	state start begin
		when login begin
			if pc.get_map_index() == 66 then
				if pc.get_x() < 4096+88 or pc.get_y() < 6656+577 or pc.get_x() > 4096+236 or pc.get_y() > 6656+737 then
					pc.warp(590500, 110500)
				end
				pc.set_warp_location(65, 5905, 1105)
			elseif pc.get_map_index() >= 660000 and pc.get_map_index() < 670000 then
				pc.set_warp_location(65, 5905, 1105)
			end
		end
		when deviltower_man.chat.locale.deviltower_man_chat begin
			if pc.get_level() < 40 then
				say_title("Strażnik Wieży Demonów: ")
				say(locale.deviltower_man_say_you_cant)
				say("")
			else
				say_title("Strażnik Wieży Demonów: ")
				say(locale.deviltower_man_say)
				say("")
				local s = select(" Wejdź do wieży ","Innym razem")
				if s == 1 then
					pc.warp(421300,727000)
				else
					return
				end
			end
		end
		when devil_stone1.kill with pc.get_map_index() == 66 begin
			notice_all("Metin twardości z parteru Wieży Demonów został zniszczony.")
			notice_all("Rozpoczyna się wyprawa na demonicznego lorda.")
			timer("devil_stone1_1", 6)
		end
		when devil_stone1_1.timer begin
			local mapto7= pc.count_item(30302)
			pc.remove_item(30302,mapto7)
			local boxto7= pc.count_item(30300)
			pc.remove_item(30300,boxto7)
			d.new_jump_all(66, special.devil_tower[1][1], special.devil_tower[1][2])
			d.regen_file("data/dungeon/deviltower2_regen.txt")
			d.set_warp_at_eliminate(4, d.get_map_index(), special.devil_tower[2][1], special.devil_tower[2][2], "data/dungeon/deviltower3_regen.txt")
		end
		when devil_stone3.kill begin
			d.set_warp_at_eliminate(4, d.get_map_index(), special.devil_tower[3][1], special.devil_tower[3][2], "data/dungeon/deviltower4_regen.txt")
			d.check_eliminated()
		end
		function get_4floor_stone_pos()
			local positions = 	{
							{368, 629},
							{419, 630},
							{428, 653},
							{422, 679},
							{395, 689},
							{369, 679},
							{361, 658},
							{388, 675},
							{375, 665},
							{373, 647},
							{384, 633},
							{404, 634},
							{418, 646},
							{419, 666},
							{405, 678},
							}
			for i = 1, 14 do
			local j = number(i, 15)
			if i != j then
				local t = positions[i];
				positions[i] = positions[j];
				positions[j] = t;
			end
			end
			return positions
		end
		when 8016.kill with pc.in_dungeon() and pc.get_map_index() >= 660000 and pc.get_map_index() < 670000 begin
			d.setf("level", 4)
			local positions = deviltower_zone.get_4floor_stone_pos()
			for i = 1, 14 do
			--chat(positions[i][1], positions[i][2])
			d.set_unique("fake" .. i , d.spawn_mob(8017, positions[i][1], positions[i][2]))
			end
			--chat(positions[7][1], positions[7][2])
			local vid = d.spawn_mob(8017, positions[15][1], positions[15][2])
			--chat(vid)
			d.set_unique("real", vid)
			local summoner_spawn = d.spawn_mob(792, 405, 661)
			d.set_unique("summoner", summoner_spawn)
			server_loop_timer('devil_stone4_update', 10, pc.get_map_index())
			server_timer('devil_stone4_fail1', 5*60, pc.get_map_index())
			d.notice("Dotarłeś do Bramy Wyboru na 3. piętrze.");
			d.notice("Wiele kamieni Metin będzie drażnić Twoje oczy i uszy.");
			d.notice("Znajdź właściwy kamień Metin i zniszcz go w ciągu 15 minut!");
			d.notice("To prawdopodobnie jedyny sposób aby przejść dalej.");
		end
		when devil_stone4_fail1.server_timer begin
			if d.select(get_server_timer_arg()) then
			d.notice("Pozostało 10 minut!")
			server_timer('devil_stone4_fail2', 5*60, get_server_timer_arg())
			end
		end
		when devil_stone4_fail2.server_timer begin
			if d.select(get_server_timer_arg()) then
			d.notice("Pozostało 5 minut!")
			server_timer('devil_stone4_fail', 5*60, get_server_timer_arg())
			end
		end
		when devil_stone4_fail.server_timer begin
			if d.select(get_server_timer_arg()) then
			d.notice("Czas się skończył!")
			d.exit_all()
			clear_server_timer('devil_stone4_update', get_server_timer_arg())
			end
		end
		when devil_stone4_update.server_timer begin
			if d.select(get_server_timer_arg()) then
			if not d.is_unique_dead("real") then
				if d.is_unique_dead("summoner") then
					d.kill_unique("real")
					d.notice("Prawdziwy kamień metin rozpadł się w pył.")
					end
				for i = 1, 14 do
				if d.getf("fakedead" .. i) == 0 then
					if d.unique_get_hp_perc("fake" .. i) < 50 then
					d.purge_unique("fake" .. i)
					d.setf("fakedead" .. i, 1)
					d.notice("To nie ten kamień.")
					end
				end
				end
			else
				server_timer("devil_stone4_end", 5, get_server_timer_arg())
				d.notice("Wykazałeś się doskonałym słuchem i instynktem")
				d.notice("Zniszczyłeś prawdziwy kamień Metin!")
				d.notice("Za chwilę dotrzesz na 4. pietro!")
				clear_server_timer('devil_stone4_fail1', get_server_timer_arg())
				clear_server_timer('devil_stone4_fail2', get_server_timer_arg())
				clear_server_timer('devil_stone4_fail', get_server_timer_arg())
			end
			else
			server_timer('devil_stone4_stop_timer', 1, get_server_timer_arg())
			end
		end
		when devil_stone4_stop_timer.server_timer begin
			clear_server_timer('devil_stone4_update', get_server_timer_arg())
		end
		when devil_stone4_end.server_timer begin
			if d.select(get_server_timer_arg()) then
			server_timer('devil_stone5_fail1', 1*60, get_server_timer_arg())
			clear_server_timer('devil_stone4_update', get_server_timer_arg())
			d.setf("level", 5)
			d.setf("stone_count", 5)
			d.notice("Dotarłeś do zamkniętej Bramy na 4. piętrze!")
			d.notice("Znajduje się tu wiele potworów, które strzegą ")
			d.notice("tajemniczych kamieni - będziesz ich potrzebował. ")
			d.notice("Bez nich nie dostaniesz się na 5. poziom Wieży. ")
			d.notice("Zdobądź kamienie otwarcia od potworów i użyj ich, aby odblokować pieczęci.")
			d.notice("Na wykonanie tego zadania masz tylko 20 minut - śpiesz się! ")
			d.notice("Pierwsza fala pojawi się za 60 sekund.")
			d.jump_all(special.devil_tower[4][1], special.devil_tower[4][2])
			d.spawn_mob(20073, 421, 452)
			d.spawn_mob(20073, 380, 460)
			d.spawn_mob(20073, 428, 414)
			d.spawn_mob(20073, 398, 392)
			d.spawn_mob(20073, 359, 426)
			end
		end
		when devil_stone5_fail1.server_timer begin
			if d.select(get_server_timer_arg()) then
			d.notice("Czas start!")
			d.notice("Pozostało 20 minut!")
			d.set_regen_file("data/dungeon/deviltower5_regen.txt")
			server_timer('devil_stone5_fail2', 10*60, get_server_timer_arg())
			end
		end
		when devil_stone5_fail2.server_timer begin
			if d.select(get_server_timer_arg()) then
			d.notice("Pozostało 10 minut!")
			server_timer('devil_stone5_fail3', 5*60, get_server_timer_arg())
			end
		end
		when devil_stone5_fail3.server_timer begin
			if d.select(get_server_timer_arg()) then
			d.notice("Pozostało 5 minut!")
			server_timer('devil_stone5_fail', 5*60, get_server_timer_arg())
			end
		end
		when devil_stone5_fail.server_timer begin
			if d.select(get_server_timer_arg()) then
			d.notice("Czas się skończył!")
			d.exit_all()
			end
		end
		when 1062.kill with pc.in_dungeon() and d.getf("level") == 5 begin
			local KILL_COUNT_FOR_DROP_KEY = 25
			local n = d.getf("count") + 1
			d.setf("count", n)
			if n == KILL_COUNT_FOR_DROP_KEY then
			pc.give_item2(50084, 1)
			d.notice("Gracz "..pc.get_name().." znalazł kamień otwarcia.")
			d.setf("count", 0)
			end
		end
		when devil_stone5.take with item.vnum == 50084 begin
			npc.purge()
			item.remove()
			d.setf("stone_count", d.getf("stone_count") - 1)
			if d.getf("stone_count") <= 0 then
			d.setf("level", 6)
			d.clear_regen()
			d.regen_file("data/dungeon/deviltower6_regen.txt")
			d.notice("Wszystkie pieczęci zostały otwarte.")
			d.notice("Teraz dotrzesz na 5. poziom Wieży Demonów. ")
			d.notice("Zabij Elit. Króla Demonów aby porozmawiać z kowalem. ")
			d.jump_all(special.devil_tower[5][1], special.devil_tower[5][2])
			clear_server_timer('devil_stone5_fail1', get_server_timer_arg())
			clear_server_timer('devil_stone5_fail2', get_server_timer_arg())
			clear_server_timer('devil_stone5_fail3', get_server_timer_arg())
			clear_server_timer('devil_stone5_fail', get_server_timer_arg())
			else
			d.notice("Otworzyłeś pieczęć! Zostało jeszcze: "..d.getf("stone_count")..".")
			end
		end
		when devil_stone6.kill with pc.in_dungeon() and pc.get_map_index() >= 660000 and pc.get_map_index() < 670000 and d.getf("level") == 6 begin
			d.kill_all()
			d.check_eliminated()
			local reward_alchemist = {20074, 20075, 20076}
			d.spawn_mob(reward_alchemist[number(1,3)], 425, 216);
			d.setqf("can_refine", 1)
		end
		
		when 20074.chat."Wyższe piętro" with pc.in_dungeon() and pc.get_map_index() >= 660000 and pc.get_map_index() < 670000 and npc.lock() begin
			say_title("Zbrojmistrz Wieży Demonów ")
			d.notice("Gracz "..pc.get_name().." rozmawia z kowalem.")
			say("Co?! Chcesz udać się na 6. poziom Wieży? ")
			say("Wyprawa na wyższe poziomy wymaga")
			say("naprawdę dobrego przygotowania.")
			say("Jeżeli osiągnąłeś 75 poziom mogę ")
			say("przenieść Was na wyższe piętro.")
			say("")
			wait()
			if pc.level >=75 then
				say_title("Zbrojmistrz Wieży Demonów ")
				say("Masz odpowiedni poziom i dlatego masz spore ")
				say("szanse na przetrwanie na wyższych piętrach.")
				say("Mozesz wejść")
				say("")
				timer("devil_jump_7", 6)
				npc.purge()
				return
			end
			say_title("Zbrojmistrz Wieży Demonów ")
			say("Masz zbyt niski poziom żeby przejść dalej.")
			say("Poproś kogoś innego.")
			say("")
			npc.unlock()
			return
		end
		when 20075.chat."Wyższe piętro" with pc.in_dungeon() and pc.get_map_index() >= 660000 and pc.get_map_index() < 670000 and npc.lock() begin
			say_title("Platnerz Wieży Demonów ")
			d.notice("Gracz "..pc.get_name().." rozmawia z kowalem.")
			say("Co?! Chcesz udać się na 6. poziom Wieży? ")
			say("Wyprawa na wyższe poziomy wymaga")
			say("naprawdę dobrego przygotowania.")
			say("Jeżeli osiągnąłeś 75 poziom mogę ")
			say("przenieść Was na wyższe piętro.")
			wait()
			if pc.level >=75 then
				say_title("Platnerz Wieży Demonów ")
				say("Masz odpowiedni poziom i dlatego masz spore ")
				say("szanse na przetrwanie na wyższych piętrach.")
				say("Mozesz wejść. ")
				timer("devil_jump_7", 6)
				npc.purge()
				return
			end
			say_title("Platnerz Wieży Demonów ")
			say("Masz zbyt niski poziom żeby przejść dalej.")
			say("Poproś kogoś innego.")
			say("")
			npc.unlock()
			return
		end
		when 20076.chat."Wyższe piętro" with pc.in_dungeon() and pc.get_map_index() >= 660000 and pc.get_map_index() < 670000 and npc.lock() begin
			say_title("Jubiler Wieży Demonów ")
			d.notice("Gracz "..pc.get_name().." rozmawia z kowalem.")
			say("Co?! Chcesz udać się na 6. poziom Wieży? ")
			say("Wyprawa na wyższe poziomy wymaga")
			say("naprawdę dobrego przygotowania.")
			say("Jeżeli osiągnąłeś 75. poziom mogę ")
			say("przenieść Was na wyższe piętro.")
			wait()
			if pc.level >=75 then
				say_title("Jubiler Wieży Demonów ")
				say("Masz odpowiedni poziom i dlatego masz spore ")
				say("szanse na przetrwanie na wyższych piętrach.")
				say("")
				timer("devil_jump_7", 6)
				npc.purge()
				return
			end
			say_title("Jubiler Wieży Demonów ")
			say("Masz zbyt niski poziom żeby przejść dalej.")
			say("Poproś kogoś innego.")
			say("")
			npc.unlock()
			return
		end
		when devil_jump_7.timer begin
			d.notice("Mapa Zin-Sa-Gui otwiera drogę na następne piętro.")
			d.notice("Zniszcz kamienie Metin, aby ją odnaleźć.")
			d.clear_regen()
			d.spawn_mob(8018, 639, 658)
			d.spawn_mob(8018, 611, 637)
			d.spawn_mob(8018, 596, 674)
			d.spawn_mob(8018, 629, 670)
			d.setf("level", 7)
			d.setf("use_once", 0)
			d.jump_all(4096+590, 6656+638)
		end
		when 8018.kill with pc.in_dungeon() and pc.get_map_index() >= 660000 and pc.get_map_index() < 670000 begin
			local cont = d.getf("7_stone_kill") + 1
			d.setf("7_stone_kill", cont)
			if cont >= 4 then
				d.setf("7_stone_kill", 0)
				d.set_regen_file("data/dungeon/deviltower7_regen.txt")
			end
		end
		when 8019.kill with pc.in_dungeon() and pc.get_map_index() >= 660000 and pc.get_map_index() < 670000 begin
			pc.give_item2(30300, 1)
		end
		when 30300.use with pc.in_dungeon() and pc.get_map_index() >= 660000 and pc.get_map_index() < 670000 begin
			pc.remove_item("30300", 1)
			local pct = number(1,10)
			if pct == 1 then
				pc.give_item2(30302, 1)
				d.notice("Gracz "..pc.get_name().." odnalazł mapę na kolejne piętro.")
				d.clear_regen()
				
			else
				pc.give_item2(30301, 1)
			end
		end
		when 30302.use with pc.in_dungeon() and pc.get_map_index() >= 660000 and pc.get_map_index() < 670000 and d.getf("use_once") == 0 and d.getf("level") == 7 begin
			say_title("Informacja:")
			say("Odnalazłeś drogę na kolejny poziom Wieży Demonów.")
			say("")
			d.setf("use_once", 1)
			local mapto7s = pc.count_item(30302)
			pc.remove_item(30302, mapto7s)
			local boxto7s = pc.count_item(30300)
			pc.remove_item(30300, boxto7s)
			timer("devil_jump_8", 6)
			d.clear_regen()
		end
		when devil_jump_8.timer begin
			d.notice("Znajdź odpowiedni klucz!")
			d.notice("Potrzebujesz klucza Zin-Bong-In aby")
			d.notice("móc otworzyć pieczęć Sa-Soein i dostać ")
			d.notice("się na następne piętro Wieży.")
			d.setf("level", 8)
			d.jump_all(4096+590, 6656+403)
			d.set_regen_file("data/dungeon/deviltower8_regen.txt")
			d.spawn_mob(20366, 640, 460)
			local _count= pc.count_item(30302)
			pc.remove_item(30302,_count)
		end
		when 1040.kill with pc.in_dungeon() and pc.get_map_index() >= 660000 and pc.get_map_index() < 670000 and d.getf("level") == 8 begin
			local pct1 = number(1, 5)
			if pct1 == 1 then
				local pct2 = number(1, 5)
				if pct2 == 1 then
					pc.give_item2(30304, 1)
				else
					pc.give_item2(30303, 1)
				end
			else
				return
			end
		end
		when 20366.take with item.vnum == 30304 begin
			npc.purge()
			item.remove()
			timer("devil_jump_9", 6)
		end
		when devil_jump_9.timer begin
			d.notice("Zabij Przywódcę Demonów! ")
			d.setf("level", 9)
			d.jump_all(4096+590, 6656+155)
			d.clear_regen()
			d.regen_file("data/dungeon/deviltower9_regen.txt")
		end
		when 1093.kill with pc.in_dungeon() and pc.get_map_index() >= 660000 and pc.get_map_index() < 670000 and d.getf("level") == 9 begin
			notice_all(pc.get_name().." zadał śmiertelny cios w cień Umarłego Rozpruwacza." )
			notice_all("Piekielny lord został wygnany z powrotem do piekła.")
			d.notice("Wyprawa zakończy się za 30 sekund.")
			timer("devil_end_jump", 30)
		end
		when devil_end_jump.timer begin
			d.exit_all()
		end
	end
end
