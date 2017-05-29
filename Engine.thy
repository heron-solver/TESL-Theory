theory Engine
imports
    Main
    "TESL"
    "RunConsistency"
    "$ISABELLE_HOME/src/HOL/Eisbach/Eisbach_Tools" 

begin
text{* Operational steps *}

abbreviation NoSporadic :: "TESL_formula \<Rightarrow> TESL_formula" where 
  "NoSporadic f \<equiv> (List.filter (\<lambda>f\<^sub>a\<^sub>t\<^sub>o\<^sub>m. case f\<^sub>a\<^sub>t\<^sub>o\<^sub>m of
      \<odot> _  \<Rightarrow> False
    | \<Odot> _ \<Rightarrow> False
    | _ \<Rightarrow> True) f)"
  
(* Operational rules *)
inductive kern_step
  :: "system \<Rightarrow> instant_index \<Rightarrow> TESL_formula \<Rightarrow> TESL_formula \<Rightarrow> bool"
  ("_, _ \<Turnstile> _ \<triangleright> _" 50) where
  simulation_end:
  "set (NoSporadic \<phi>) = set \<phi> \<Longrightarrow>
   consistent_run \<Gamma> \<Longrightarrow>
   \<Gamma>, n \<Turnstile> [] \<triangleright> \<phi>"
  (* Instant introduction *)
| instant_i:
  "consistent_run \<Gamma> \<Longrightarrow>
   \<Gamma>, Suc n \<Turnstile> \<phi> \<triangleright> NoSporadic \<phi> \<Longrightarrow>
   \<Gamma>, n \<Turnstile> [] \<triangleright> \<phi>"
  (* Elimination of `sporadic` *)
| sporadic_e1:
  "consistent_run \<Gamma> \<Longrightarrow>
   \<Gamma>, n \<Turnstile> \<psi> \<triangleright> \<odot> (K, \<tau>) # \<phi> \<Longrightarrow>
   \<Gamma>, n \<Turnstile> \<odot> (K, \<tau>) # \<psi> \<triangleright> \<phi>"
| sporadic_e2:
  "consistent_run (\<Up>(K, n) # \<Down>(K, n, \<tau>) # \<Gamma>) \<Longrightarrow>
   \<Up>(K, n) # \<Down>(K, n, \<tau>) # \<Gamma>, n \<Turnstile> \<psi> \<triangleright> \<phi> \<Longrightarrow>
   \<Gamma>, n \<Turnstile> \<odot> (K, \<tau>) # \<psi> \<triangleright> \<phi>"
  (* Elimination of `sporadic on` *)
| sporadic_on_e1:
  "consistent_run \<Gamma> \<Longrightarrow>
   \<Gamma>, n \<Turnstile> \<psi> \<triangleright> \<Odot> (K\<^sub>1, \<tau>, K\<^sub>2) # \<phi> \<Longrightarrow>
   \<Gamma>, n \<Turnstile> \<Odot> (K\<^sub>1, \<tau>, K\<^sub>2) # \<psi> \<triangleright> \<phi>"
| sporadic_on_e2:
  "consistent_run (\<Up>(K\<^sub>2, n) # \<Down>(K\<^sub>1, n, \<tau>) # \<Gamma>) \<Longrightarrow>
   \<Up>(K\<^sub>2, n) # \<Down>(K\<^sub>1, n, \<tau>) # \<Gamma>, n \<Turnstile> \<psi> \<triangleright> \<phi> \<Longrightarrow>
   \<Gamma>, n \<Turnstile> \<Odot> (K\<^sub>1, \<tau>, K\<^sub>2) # \<psi> \<triangleright> \<phi>"
  (* Elimination of `tag relation` *)
| tagrel_e:
  "consistent_run (\<doteq>(\<tau>\<^sub>v\<^sub>a\<^sub>r(K\<^sub>1, n), \<alpha>, \<tau>\<^sub>v\<^sub>a\<^sub>r(K\<^sub>2, n), \<beta>) # \<Gamma>) \<Longrightarrow>
   \<doteq>(\<tau>\<^sub>v\<^sub>a\<^sub>r(K\<^sub>1, n), \<alpha>, \<tau>\<^sub>v\<^sub>a\<^sub>r(K\<^sub>2, n), \<beta>) # \<Gamma>, n \<Turnstile> \<psi> \<triangleright> \<phi> \<Longrightarrow>
   \<Gamma>, n \<Turnstile> \<rightleftharpoons>\<^sub>t\<^sub>a\<^sub>g\<^sub>r\<^sub>e\<^sub>l (K\<^sub>1, \<alpha>, K\<^sub>2, \<beta>) # \<psi> \<triangleright> \<phi>"
  (* Elimination of `implies` *)
| implies_e1:
  "consistent_run (\<not>\<Up>(K\<^sub>1, n) # \<Gamma>) \<Longrightarrow>
   \<not>\<Up>(K\<^sub>1, n) # \<Gamma>, n \<Turnstile> \<psi> \<triangleright> \<phi> \<Longrightarrow>
   \<Gamma>, n \<Turnstile> (K\<^sub>1 \<rightarrow>\<^sub>i\<^sub>m\<^sub>p\<^sub>l\<^sub>i\<^sub>e\<^sub>s K\<^sub>2) # \<psi> \<triangleright> \<phi>"
| implies_e2:
  "consistent_run (\<Up>(K\<^sub>1, n) # \<Up>(K\<^sub>2, n) # \<Gamma>) \<Longrightarrow>
   \<Up>(K\<^sub>1, n) # \<Up>(K\<^sub>2, n) # \<Gamma>, n \<Turnstile> \<psi> \<triangleright> \<phi> \<Longrightarrow>
   \<Gamma>, n \<Turnstile> (K\<^sub>1 \<rightarrow>\<^sub>i\<^sub>m\<^sub>p\<^sub>l\<^sub>i\<^sub>e\<^sub>s K\<^sub>2) # \<psi> \<triangleright> \<phi>"
  (* Elimination of `time delayed by` *)
| timedelayed_e1:
  "consistent_run (\<not>\<Up>(K\<^sub>1, n) # \<Gamma>) \<Longrightarrow>
   \<not>\<Up>(K\<^sub>1, n) # \<Gamma>, n \<Turnstile> \<psi> \<triangleright> \<phi> \<Longrightarrow>
   \<Gamma>, n \<Turnstile> \<rightarrow>\<^sub>t\<^sub>i\<^sub>m\<^sub>e\<^sub>d\<^sub>e\<^sub>l\<^sub>a\<^sub>y\<^sub>e\<^sub>d (K\<^sub>1, \<delta>\<tau>, K\<^sub>2, K\<^sub>3) # \<psi> \<triangleright> \<phi>"
| timedelayed_e2:
  "consistent_run (\<Up>(K\<^sub>1, n) # \<Down>(K\<^sub>2, n, \<tau>\<^sub>v\<^sub>a\<^sub>r(K\<^sub>2, n)) # \<Gamma>) \<Longrightarrow>
   \<Up>(K\<^sub>1, n) # \<Down>(K\<^sub>2, n, \<tau>\<^sub>v\<^sub>a\<^sub>r(K\<^sub>2, n)) # \<Gamma>, n \<Turnstile> \<psi> \<triangleright> \<Odot>(K\<^sub>3, \<tau>\<^sub>v\<^sub>a\<^sub>r(K\<^sub>2, n), K\<^sub>2) # \<phi> \<Longrightarrow>
   \<Gamma>, n \<Turnstile> \<rightarrow>\<^sub>t\<^sub>i\<^sub>m\<^sub>e\<^sub>d\<^sub>e\<^sub>l\<^sub>a\<^sub>y\<^sub>e\<^sub>d (K\<^sub>1, \<delta>\<tau>, K\<^sub>2, K\<^sub>3) # \<psi> \<triangleright> \<phi>"

named_theorems init
declare instant_i [init]

named_theorems elims
declare sporadic_e2 [elims]
declare sporadic_e1 [elims]
declare implies_e2 [elims]
declare implies_e1 [elims]

method heron_step_continue =
  rule init, auto, solve_run_witness, (rule elims, solve_run_witness)+

method heron_step_end =
  rule simulation_end, simp, solve_run_witness'


end