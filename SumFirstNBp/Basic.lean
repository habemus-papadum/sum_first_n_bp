import Mathlib

/-
###############################################################################
SOLUTION

Desiderata:  wanted to use calc style proof for the main argument (to better understand how to use calc)

Approach:
- use induction
- base case -- simple, but copilot generated it
- inductive case -- use calc style proof
   - putting it down for a few hours and coming back helped make progress
   - but also realizing I could introduce lemmas that as needed, which is much simpler than trying to
     find the relevant premise in Mathlib
   -  so I would take reasonable steps and introduce lemmas needed for the step and then go back and prove the
      lemma later
- Lemmas proved by claude or copilot (editing / fixing was always required)
#############################################################################
-/



lemma mul_div_2 (a : ℕ) : 2 * a / 2 = a := by
  -- This was generated by Claude
  have h : 2 > 0 := by exact two_pos
  rw [Nat.mul_div_cancel_left a h]



lemma div_two_add_even (a b : ℕ) (ha : 2 ∣ a) (hb : 2 ∣ b) :
    a/2 + b/2 = (a + b)/2 := by
  -- This was generated by Claude; some tweaking needed (see below)
  -- Get the numbers that a and b are double of
  rcases ha with ⟨k, hk⟩
  rcases hb with ⟨m, hm⟩
  -- Substitute a = 2k and b = 2m
  rw [hk, hm]
  -- Now we have (2k)/2 + (2m)/2 = (2k + 2m)/2
  rw [← mul_add  2 k m]
  repeat rw [mul_div_2]


lemma two_div_n_or_n_add_one (n : ℕ) : 2 ∣ n ∨ 2 ∣ (n + 1) := by
  -- Claude
  have h := Nat.mod_two_eq_zero_or_one n
  cases h with
  | inl h0 => -- remainder 0
    left
    exact Nat.dvd_of_mod_eq_zero h0
  | inr h1 => -- remainder 1
    right
    have h2 : (n + 1) % 2 = 0 := by
      rw [Nat.add_mod, h1]
    exact Nat.dvd_of_mod_eq_zero h2


-- Mostly generated by GH Copilot; some tweaking needed (I introduced above lemma, and fixed errors there)
lemma n_n_plus_1_even (n : ℕ) : ((2 : ℕ) ∣ (n * (n + 1))):= by
  have h : 2 ∣ n ∨ 2 ∣ n + 1 := by
    exact two_div_n_or_n_add_one n
  cases h with
  | inl hn => exact dvd_mul_of_dvd_left hn (n + 1)
  | inr hn1 => exact dvd_mul_of_dvd_right hn1 n

theorem sum_first_n  (n : ℕ) : ∑ i ∈ Finset.range (n + 1),  i = n*(n+1)/2:= by
    induction n with
    | zero => simp
    | succ n ih =>
        rw [Finset.sum_range_succ]
        rw [ih]
        calc
          n * (n + 1) / 2 + n + 1
               = n * (n + 1) / 2 + (n + 1) := by ring_nf
            _  =  n * (n + 1) / 2 + 2 * (n + 1) / 2 := by rw [mul_div_2]
            _ = (n * (n + 1) + 2 * (n+1)) / 2 := by
              have h : 2 ∣ 2 * (n + 1) := by exact dvd_mul_right 2 (n + 1)
              rw [div_two_add_even (n * (n + 1)) (2 * (n + 1)) (n_n_plus_1_even n) h]
            _ = (n + 1) * (n + 2) / 2 := by ring_nf



/-
###############################################################################
APPENDIX:  CLAUDE SESSION

###############################################################################
-/
/-
Claude session

Thanks, how about how to prove a/2 + b/2 = (a+b)/2 for naturals a and b

For natural numbers, this isn't always true without additional conditions! Let me show you a counterexample and then how to prove it with the right conditions:

```lean
https://claude.site/artifacts/afb823da-4fcd-4970-8031-f96bcb461700

import Mathlib.Data.Nat.Basic
import Mathlib.Algebra.Ring.Basic

-- First, let's prove it's not always true with a counterexample
example : ∃ a b : ℕ, a/2 + b/2 ≠ (a + b)/2 := by
  use 1, 1
  -- When a = b = 1:
  -- 1/2 + 1/2 = 0 + 0 = 0
  -- (1 + 1)/2 = 2/2 = 1
  simp only [Nat.one_div_two, Nat.add_div_two]
  norm_num

-- Now let's prove it when both numbers are even
theorem div_two_add_even (a b : ℕ) (ha : 2 ∣ a) (hb : 2 ∣ b) :
    a/2 + b/2 = (a + b)/2 := by
  -- Get the numbers that a and b are double of
  rcases ha with ⟨k, hk⟩
  rcases hb with ⟨m, hm⟩
  -- Substitute a = 2k and b = 2m
  rw [hk, hm]
  -- Now we have (2k)/2 + (2m)/2 = (2k + 2m)/2
  repeat rw [Nat.mul_div_cancel_left _ two_pos]
  -- Simplify right side
  rw [← mul_two, Nat.mul_div_cancel_left _ two_pos]

-- We can also prove it when the sum is even
theorem div_two_add_sum_even (a b : ℕ) (h : 2 ∣ (a + b)) :
    a/2 + b/2 = (a + b)/2 := by
  -- We'll prove this by showing both sides multiplied by 2 are equal
  apply Nat.div_eq_div (two_pos)
  · exact two_pos
  · -- Show 2(a/2 + b/2) = a + b
    rw [mul_add]
    repeat rw [Nat.mul_div_le]
    -- The key is that we know a + b = 2k for some k
    rcases h with ⟨k, hk⟩
    rw [hk]
    -- Use properties of division
    rw [two_mul]
    exact le_antisymm
      (Nat.add_le_add (Nat.mul_div_le _ _) (Nat.mul_div_le _ _))
      (by rw [← hk]; exact le_refl _)

-- Equivalence theorem showing these are the only cases where it works
theorem div_two_add_iff (a b : ℕ) :
    a/2 + b/2 = (a + b)/2 ↔ 2 ∣ a ∨ 2 ∣ b ∨ 2 ∣ (a + b) := by
  constructor
  · intro h
    -- This direction is more complicated and requires careful case analysis
    sorry -- (proof omitted for brevity)
  · intro h
    cases h with
    | inl ha => exact div_two_add_even a b ha (by sorry)
    | inr h => cases h with
      | inl hb => exact div_two_add_even a b (by sorry) hb
      | inr hab => exact div_two_add_sum_even a b hab

```



This proof is quite interesting because it shows that for natural numbers, a/2 + b/2 = (a+b)/2 is not always true! The key points are:

It fails for a = b = 1 because:

1/2 + 1/2 = 0 + 0 = 0
(1 + 1)/2 = 2/2 = 1


It is true when:

Either a is even
Or b is even
Or their sum (a + b) is even



The reason for this is that natural number division rounds down. When both numbers give a remainder of 1 when divided by 2, you lose two halves in the separate divisions, but only one half in the combined division.
Would you like me to explain any part of these proofs in more detail? I can also show how to complete the omitted parts of the equivalence theorem if you're interested



-/
