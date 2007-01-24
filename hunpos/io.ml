(*
let read_sentence chan = 
	(* returns the next field of the TAB separated line and the next character 
		pos after the field *)
	
  let next_item line  start = 
  	let len = String.length line in
     	let next_tab_pos = 
        	try  
          	String.index_from line start '\t'
        	with 
          	| Not_found -> len
          	| Invalid_argument _ ->
               	Printf.eprintf "ERROR: not enough fields. Input line follows\n%s\n" line;
               	raise (Failure "not enough fields") 
				in
				
       			let item = String.sub line start (next_tab_pos - start) in
						(next_tab_pos +1), item
	
	in
		let rec read_sentence empty =   (* h�vhatod ugyan�gy a rekurz�v seg�df�ggv�nyt *)
			let line =
				try input_line chan
				with 
				 End_of_file -> match empty with
					                | true -> raise End_of_file
									| false -> ""
			in
			let last, word = next_item line 0 in    (* beolvassuk a sz�t, ha nincs akkor az end 0 lesz *)
			match word, empty with
			| "", true -> read_sentence true (* consume redundant newlines if sentence is empty yet *)
			| "", false -> []                    (* genuine end of non_empty sentence *)
			| _, _ ->                           (* next real item *)
				let _, gold =
					try
							 next_item line last
					with _ -> Printf.eprintf "invalid line %d %s\n" last line; failwith "invalid line"
				in
				(word, gold) :: read_sentence false (* m�r tudjuk, hogy nem �res a mondat *)
		in
					read_sentence true
;;


let read_sentence_no_split chan =
		let rec read_sentence empty =   (* h�vhatod ugyan�gy a rekurz�v seg�df�ggv�nyt *)
			let line =
				try input_line chan
				with 
				 End_of_file -> match empty with
					                | true -> raise End_of_file
									| false -> ""
			in
		
			match String.length line, empty with
			| 0, true -> read_sentence true (* consume redundant newlines if sentence is empty yet *)
			| 0, false -> []                    (* genuine end of non_empty sentence *)
			| _, _ ->                           (* next real item *)
				line:: read_sentence false (* m�r tudjuk, hogy nem �res a mondat *)
		in
					read_sentence true
;;

(* vegigmegy a chan minden mondatan is atadja az f-nek*)
let iter_sentence_no_split chan f =
	let rec loop () = 
		f (read_sentence_no_split chan);
		loop()
	in
	try
		loop () ;
	with End_of_file -> ()

;;


*)
let read_sentence chan =
	let rec aux wacc tacc read=
		try 
		match Parse.split2 '\t' (input_line chan) with
			word :: r when (String.length word) > 0 -> 
				let gold = match r with
					x :: r -> x
					| _ -> ""
				in
				aux (word :: wacc) (gold::tacc) true
			| _ -> (wacc, tacc)
		with End_of_file -> if read then (wacc, tacc) else raise End_of_file
	in
	aux ([]) ([]) false
	
let iter_sentence chan f =
	try
		while(true) do
			f (read_sentence chan)
		done;
	with End_of_file -> ()
			
	
(*

(* vegigmegy a chan minden mondatan is atadja az f-nek*)
let iter_sentence chan f =
	let rec loop () = 
		f (read_sentence chan);
		loop()
	in
	try
		loop () ;
	with End_of_file -> ()

;;
*)
	
let rec fold_sentence f a chan =
	 try
	 	let (words, tags) = read_sentence chan in
		let sentence = List.combine words tags in
	 	fold_sentence f (f a sentence) chan
	with End_of_file -> a

