% begum yivli
% 2019400147
% compiling: yes
% complete: no
:- ['cmpecraft.pro'].

:- init_from_map.

% 10 points
% manhattan_distance(+A, +B, -Distance) :- .
manhattan_distance([],[], 0).
manhattan_distance([Hf|Tf], [He|Te], Dist) :- manhattan_distance(Tf, Te, Dist2), Dist is Dist2 + abs(Hf-He).

% 10 points
% minimum_of_list(+List, -Minimum) :- .
minimum_of_list([X], X).
minimum_of_list([X, Y | T],Min) :- X =< Y, !, minimum_of_list([X | T], Min).
minimum_of_list([_, Y | T], Min) :- minimum_of_list([Y | T], Min).

% 10 points
% find_nearest_type(+State, +ObjectType, -ObjKey, -Object, -Distance) :- .
find_nearest_type(State, ObjectType, Objkey, Object, Distance) :-nth0(0, State, Agent), nth0(1, State, Ob), dict_pairs(Ob, Tag, Pairs), length(Pairs, Len), Mylen is Len - 1, dict_create(Dict2, Tagg, []), finding(State, ObjectType, Objkey, Object, Distance, Mylen, Dict2).
finding(State, ObjectType, Objkey, Obj, Distance, Key, Dict) :- nth0(0, State, Agent), nth0(1, State, O), Key >= 0,  not(get_dict(Key, O, D)), X1 is Key-1, finding(State, ObjectType, Objkey, Obj, Distance, X1, Dict).
finding(State, ObjectType, Objkey, Obj, Distance, Key, Dict) :- nth0(0, State, Agent), nth0(1, State, O), Key >= 0,  get_dict(Key, O, D), get_dict(type, D, Type), ObjectType = Type, get_dict(x, D, Val1), get_dict(y, D, Val2), Dist is abs(Agent.x-Val1) + abs(Agent.y-Val2), X1 is Key-1, put_dict(Dist, Dict, Key, Newdict), finding(State, ObjectType, Objkey, Obj, Distance, X1, Newdict).
finding(State, ObjectType, Objkey, Obj, Distance, Key, Dict) :- nth0(0, State, Agent), nth0(1, State, O), Key >= 0, get_dict(Key, O, D), get_dict(type, D, Type), not(ObjectType = Type), X1 is Key-1, finding(State, ObjectType, Objkey, Obj, Distance, X1, Dict).
finding(State, ObjectType, Objkey, Obj, Distance, Key, Dict) :- nth0(1, State, O), Key is -1, !, dict_pairs(Dict, Tag, Mypair), pairs_keys(Mypair, Keys), minimum_of_list(Keys, Min), get_dict(Min, Dict, Id), get_dict(Id, O, D), Objkey is Id, Distance is Min, get_dict(Id, O, Obj). 

% 10 points
% navigate_to(+State, +X, +Y, -ActionList, +DepthLimit) :- .
navigate_to(State, X, Y, ActionList, DepthLimit) :-nth0(0,State,Agent), get_dict(x, Agent, K), get_dict(y, Agent, L), A is abs(K-X) +abs(L-Y), A =< DepthLimit, myfnc(State, X, Y, [], ActionList).
myfnc(State, X, Y, L2,L3) :- nth0(0,State,Agent), X is Agent.x, myfnc2(State, X, Y, L2, L3).
myfnc(State, X, Y, L,L3) :- nth0(0,State,Agent), X > Agent.x, !, X1 is X-1, append(L,[go_right],L2), myfnc(State, X1, Y, L2,L3).
myfnc(State, X, Y, L,L3) :- nth0(0,State,Agent), X < Agent.x, !, X1 is X+1, append(L,[go_left],L2), myfnc(State, X1, Y, L2,L3).
myfnc2(State, X, Y, L,L3) :- nth0(0,State,Agent), Y < Agent.y, Y1 is Y+1, append(L,[go_up],L2), myfnc2(State, X, Y1, L2,L3).
myfnc2(State, X, Y, L,L3) :- nth0(0,State,Agent), Y > Agent.y, Y1 is Y-1, append(L,[go_down],L2), myfnc2(State, X, Y1, L2,L3).
myfnc2(State, X, Y, L2,L2) :- nth0(0,State,Agent), Y is Agent.y, !.

% 10 points
% chop_nearest_tree(+State, -ActionList) :- .
chop_nearest_tree(State, ActionList) :- find_nearest_type(State, tree, Objkey, Object, Distance), navigate_to(State, Object.x, Object.y, L2, Distance), append(L2, [left_click_c, left_click_c, left_click_c, left_click_c], ActionList).

% 10 points
% mine_nearest_stone(+State, -ActionList) :- .
mine_nearest_stone(State, ActionList) :- find_nearest_type(State, stone, Objkey, Object, Distance), navigate_to(State, Object.x, Object.y, L2, Distance), append(L2, [left_click_c, left_click_c, left_click_c, left_click_c], ActionList).

mine_nearest_cobblestone(State, ActionList) :- find_nearest_type(State, cobblestone, Objkey, Object, Distance), navigate_to(State, Object.x, Object.y, L2, Distance), append(L2, [left_click_c, left_click_c, left_click_c, left_click_c], ActionList).

% 10 points
% gather_nearest_food(+State, -ActionList) :- .
gather_nearest_food(State, ActionList) :- find_nearest_type(State, food, Objkey, Object, Distance), navigate_to(State, Object.x, Object.y, L2, Distance), append(L2, [left_click_c], ActionList).

% 10 points
% collect_requirements(+State, +ItemType, -ActionList) :- .
collect_requirements(State, ItemType, ActionList) :- nth0(0,State,A), ItemType = stick, not(get_dict(log, A.inventory, Val)), chop_nearest_tree(State, ActionList).
collect_requirements(State, ItemType, ActionList) :- nth0(0,State,A), ItemType = stick, get_dict(log, A.inventory, Val), (Val < 2 -> chop_nearest_tree(State, ActionList) ; ActionList = []).

collect_requirements(State, ItemType, ActionList) :- nth0(0,State,A), ItemType = stone_pickaxe, not(get_dict(log, A.inventory, Log)), not(get_dict(stick, A.inventory, Stick)), not(get_dict(cobblestone, A.inventory, Cobble)), !,
chop_nearest_tree(State, L2), execute_actions(State, L2, State2), chop_nearest_tree(State2, L3), execute_actions(State2, L3, State3), mine_nearest_stone(State3, Lstone),
execute_actions(State3, Lstone, Finalstate), append(L2, L3, Le), append(Le, Lstone , Lo),  append(Lo, [craft_stick], ActionList).

collect_requirements(State, ItemType, ActionList) :- nth0(0,State,A), ItemType = stone_pickaxe, not(get_dict(log, A.inventory, Log)), not(get_dict(stick, A.inventory, Stick)), get_dict(cobblestone, A.inventory, Cobble),
(Cobble < 3 -> chop_nearest_tree(State, L2), execute_actions(State, L2, State2), chop_nearest_tree(State2, L3), execute_actions(State2, L3, State3), mine_nearest_stone(State3, Lstone),
execute_actions(State3, Lstone, Finalstate), append(L2, L3, Le), append(Le, Lstone , Lo),  append(Lo, [craft_stick], ActionList) ;
chop_nearest_tree(State, L2), execute_actions(State, L2, State2), chop_nearest_tree(State2, L3), execute_actions(State2, L3, State3), append(L2, L3, Le), append(Le, [craft_stick], ActionList)).

collect_requirements(State, ItemType, ActionList) :- nth0(0,State,A), ItemType = stone_pickaxe, not(get_dict(log, A.inventory, Log)), not(get_dict(cobblestone, A.inventory, Cobble)), get_dict(stick, A.inventory, Stick),
(Stick < 2 -> chop_nearest_tree(State, L2), execute_actions(State, L2, State2), chop_nearest_tree(State2, L3), execute_actions(State2, L3, State3), mine_nearest_stone(State3, Lstone),
execute_actions(State3, Lstone, Finalstate), append(L2, L3, Le), append(Le, Lstone , Lo),  append(Lo, [craft_stick], ActionList) ; chop_nearest_tree(State, L2), execute_actions(State, L2, State2), mine_nearest_stone(State2, Lstone),
execute_actions(State2, Lstone, Finalstate), append(L2, Lstone, ActionList)).

collect_requirements(State, ItemType, ActionList) :- nth0(0,State,A), ItemType = stone_pickaxe, not(get_dict(log, A.inventory, Log)), get_dict(cobblestone, A.inventory, Cobble), get_dict(stick, A.inventory, Stick),
(Stick < 2 -> chop_nearest_tree(State, L2), execute_actions(State, L2, State2), chop_nearest_tree(State2, L3), execute_actions(State2, L3, State3), mine_nearest_stone(State3, Lstone),
execute_actions(State3, Lstone, Finalstate), append(L2, L3, Le), append(Le, Lstone , Lo),  append(Lo, [craft_stick], ActionList) ; chop_nearest_tree(State, L2), execute_actions(State, L2, State2), mine_nearest_stone(State2, Lstone),
execute_actions(State2, Lstone, Finalstate), append(L2, Lstone, ActionList)).

collect_requirements(State, ItemType, ActionList) :- nth0(0,State,A), ItemType = stone_pickaxe, get_dict(log, A.inventory, Log), not(get_dict(cobblestone, A.inventory, Cobble)), not(get_dict(stick, A.inventory, Stick)),
(Log < 3 -> chop_nearest_tree(State, L2), execute_actions(State, L2, State2), chop_nearest_tree(State2, L3), execute_actions(State2, L3, State3), mine_nearest_stone(State3, Lstone),
execute_actions(State3, Lstone, Finalstate), append(L2, L3, Le), append(Le, Lstone , Lo),  append(Lo, [craft_stick], ActionList) ; chop_nearest_tree(State, L2), execute_actions(State, L2, State2), mine_nearest_stone(State2, Lstone),
execute_actions(State2, Lstone, Finalstate), append(L2, Lstone, L3), append(L3, [craft_stick], ActionList)).

collect_requirements(State, ItemType, ActionList) :- nth0(0,State,A), ItemType = stone_pickaxe, get_dict(log, A.inventory, Log), not(get_dict(cobblestone, A.inventory, Cobble)), get_dict(stick, A.inventory, Stick),
(Stick < 2 -> chop_nearest_tree(State, L2), execute_actions(State, L2, State2), chop_nearest_tree(State2, L3), execute_actions(State2, L3, State3), mine_nearest_stone(State3, Lstone),
execute_actions(State3, Lstone, Finalstate), append(L2, L3, Le), append(Le, Lstone , Lo),  append(Lo, [craft_stick], ActionList) ; chop_nearest_tree(State, L2), execute_actions(State, L2, State2), mine_nearest_stone(State2, L3), append(L2, L3, ActionList)).

collect_requirements(State, ItemType, ActionList) :- nth0(0,State,A), ItemType = stone_pickaxe, get_dict(log, A.inventory, Log), get_dict(cobblestone, A.inventory, Cobble), not(get_dict(stick, A.inventory, Stick)),
(Cobble < 3 -> chop_nearest_tree(State, L2), execute_actions(State, L2, State2), chop_nearest_tree(State2, L3), execute_actions(State2, L3, State3), mine_nearest_stone(State3, Lstone),
execute_actions(State3, Lstone, Finalstate), append(L2, L3, Le), append(Le, Lstone , Lo),  append(Lo, [craft_stick], ActionList) ; chop_nearest_tree(State, L2), execute_actions(State, L2, State2), chop_nearest_tree(State2, L3), append(L2, L3, ActionList)).

collect_requirements(State, ItemType, ActionList) :- nth0(0,State,A), ItemType = stone_pickaxe, get_dict(log, A.inventory, Log), get_dict(cobblestone, A.inventory, Cobble), get_dict(stick, A.inventory, Stick),
ActionList = [].

collect_requirements(State, ItemType, ActionList) :- nth0(0,State,A), ItemType = stone_axe, not(get_dict(log, A.inventory, Log)), not(get_dict(stick, A.inventory, Stick)), not(get_dict(cobblestone, A.inventory, Cobble)), !,
chop_nearest_tree(State, L2), execute_actions(State, L2, State2), chop_nearest_tree(State2, L3), execute_actions(State2, L3, State3), mine_nearest_stone(State3, Lstone),
execute_actions(State3, Lstone, Finalstate), append(L2, L3, Le), append(Le, Lstone , Lo),  append(Lo, [craft_stick], ActionList).

collect_requirements(State, ItemType, ActionList) :- nth0(0,State,A), ItemType = stone_axe, not(get_dict(log, A.inventory, Log)), not(get_dict(stick, A.inventory, Stick)), get_dict(cobblestone, A.inventory, Cobble),
(Cobble < 3 -> chop_nearest_tree(State, L2), execute_actions(State, L2, State2), chop_nearest_tree(State2, L3), execute_actions(State2, L3, State3), mine_nearest_stone(State3, Lstone),
execute_actions(State3, Lstone, Finalstate), append(L2, L3, Le), append(Le, Lstone , Lo),  append(Lo, [craft_stick], ActionList) ;
chop_nearest_tree(State, L2), execute_actions(State, L2, State2), chop_nearest_tree(State2, L3), execute_actions(State2, L3, State3), append(L2, L3, Le), append(Le, [craft_stick], ActionList)).

collect_requirements(State, ItemType, ActionList) :- nth0(0,State,A), ItemType = stone_axe, not(get_dict(log, A.inventory, Log)), not(get_dict(cobblestone, A.inventory, Cobble)), get_dict(stick, A.inventory, Stick),
(Stick < 2 -> chop_nearest_tree(State, L2), execute_actions(State, L2, State2), chop_nearest_tree(State2, L3), execute_actions(State2, L3, State3), mine_nearest_stone(State3, Lstone),
execute_actions(State3, Lstone, Finalstate), append(L2, L3, Le), append(Le, Lstone , Lo),  append(Lo, [craft_stick], ActionList) ; chop_nearest_tree(State, L2), execute_actions(State, L2, State2), mine_nearest_stone(State2, Lstone),
execute_actions(State2, Lstone, Finalstate), append(L2, Lstone, ActionList)).

collect_requirements(State, ItemType, ActionList) :- nth0(0,State,A), ItemType = stone_axe, not(get_dict(log, A.inventory, Log)), get_dict(cobblestone, A.inventory, Cobble), get_dict(stick, A.inventory, Stick),
(Stick < 2 -> chop_nearest_tree(State, L2), execute_actions(State, L2, State2), chop_nearest_tree(State2, L3), execute_actions(State2, L3, State3), mine_nearest_stone(State3, Lstone),
execute_actions(State3, Lstone, Finalstate), append(L2, L3, Le), append(Le, Lstone , Lo),  append(Lo, [craft_stick], ActionList) ; chop_nearest_tree(State, L2), execute_actions(State, L2, State2), mine_nearest_stone(State2, Lstone),
execute_actions(State2, Lstone, Finalstate), append(L2, Lstone, ActionList)).

collect_requirements(State, ItemType, ActionList) :- nth0(0,State,A), ItemType = stone_axe, get_dict(log, A.inventory, Log), not(get_dict(cobblestone, A.inventory, Cobble)), not(get_dict(stick, A.inventory, Stick)),
(Log < 3 -> chop_nearest_tree(State, L2), execute_actions(State, L2, State2), chop_nearest_tree(State2, L3), execute_actions(State2, L3, State3), mine_nearest_stone(State3, Lstone),
execute_actions(State3, Lstone, Finalstate), append(L2, L3, Le), append(Le, Lstone , Lo),  append(Lo, [craft_stick], ActionList) ; chop_nearest_tree(State, L2), execute_actions(State, L2, State2), mine_nearest_stone(State2, Lstone),
execute_actions(State2, Lstone, Finalstate), append(L2, Lstone, L3), append(L3, [craft_stick], ActionList)).

collect_requirements(State, ItemType, ActionList) :- nth0(0,State,A), ItemType = stone_axe, get_dict(log, A.inventory, Log), not(get_dict(cobblestone, A.inventory, Cobble)), get_dict(stick, A.inventory, Stick),
(Stick < 2 -> chop_nearest_tree(State, L2), execute_actions(State, L2, State2), chop_nearest_tree(State2, L3), execute_actions(State2, L3, State3), mine_nearest_stone(State3, Lstone),
execute_actions(State3, Lstone, Finalstate), append(L2, L3, Le), append(Le, Lstone , Lo),  append(Lo, [craft_stick], ActionList) ; chop_nearest_tree(State, L2), execute_actions(State, L2, State2), mine_nearest_stone(State2, L3), append(L2, L3, ActionList)).

collect_requirements(State, ItemType, ActionList) :- nth0(0,State,A), ItemType = stone_axe, get_dict(log, A.inventory, Log), get_dict(cobblestone, A.inventory, Cobble), not(get_dict(stick, A.inventory, Stick)),
(Cobble < 3 -> chop_nearest_tree(State, L2), execute_actions(State, L2, State2), chop_nearest_tree(State2, L3), execute_actions(State2, L3, State3), mine_nearest_stone(State3, Lstone),
execute_actions(State3, Lstone, Finalstate), append(L2, L3, Le), append(Le, Lstone , Lo),  append(Lo, [craft_stick], ActionList) ; chop_nearest_tree(State, L2), execute_actions(State, L2, State2), chop_nearest_tree(State2, L3), append(L2, L3, ActionList)).

collect_requirements(State, ItemType, ActionList) :- nth0(0,State,A), ItemType = stone_axe, get_dict(log, A.inventory, Log), get_dict(cobblestone, A.inventory, Cobble), get_dict(stick, A.inventory, Stick),
ActionList = [].

tile_occupied1(X, Y, State) :-
    State = [_, StateDict, _],
    get_dict(_, StateDict, Object),
    get_dict(x, Object, Ox),
    get_dict(y, Object, Oy),
    X = Ox, Y = Oy.

% 5 points
% find_castle_location(+State, -XMin, -YMin, -XMax, -YMax) :- .
find_castle_location(State, XMin, YMin, XMax, YMax) :-
    State=[A,O,T], width(W),W1 is W-2,height(H),H1 is H-4,findall([X,Y],(maplist(between(1,W1 ),[X]),maplist(between(1,H1),[Y]),
    \+tile_occupied1(X,Y,State),X1 is X+1 ,\+tile_occupied1(X1,Y,State),X2 is X1+1,\+tile_occupied1(X2,Y,State),Y1 is Y+1,
    \+tile_occupied1(X,Y1,State),\+tile_occupied1(X1,Y1,State),\+tile_occupied1(X2,Y1,State), Y2 is Y1+1,
    \+tile_occupied1(X,Y2,State),\+tile_occupied1(X1,Y2,State),\+tile_occupied1(X2,Y2,State)    
    ),Bag),member([XMin,YMin],Bag),XMax is XMin +2, YMax is YMin+2 .

% 15 points
% make_castle(+State, -ActionList) :- .
make_castle(State,ActionList) :-
    State=[A,O,T], get_dict(inventory, A, Inv),
    get_CobC(Inv,CobblestoneCount),Cc is CobblestoneCount-9, 
    collect_tool(State,NS,0,Cc,0,[],ActionList1),NS=[A1,O1,T1], get_dict(x,A,Ax),get_dict(y,A,Ay),
    find_castle_location(State, XMin, YMin, XMax, YMax), CX is XMin +1, CY is YMin+1, manhattan_distance([Ax,Ay],[CX,CY],Dist),
    navigate_to(NS, CX, CY, ActionList2, Dist),append(ActionList1,ActionList2,ActionList3),
    append(ActionList3,[place_c,place_n,place_e,place_w,place_s,place_ne,place_nw,place_se,place_sw],ActionList)    .


