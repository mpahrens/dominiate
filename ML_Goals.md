== Goals for COMP150AML ==
- Be able to run fresh simulator, with copied state, at any point.
- Represent a strategy aggregator which is a strategy of switching over strategies
- Represent a strategy transformer which is a strategy with methods to change its parameters.
- Be able to query the policy collection
- policy switching: to make decisions of which expert policy to follow against a fixed set of cards and opponent strategy
- policy gradient / policy search: to improve upon a base policy by tweaking parameters against a fixed set of cards and opponent strategy.

== Info ==
- play.coffee has main state game loop
    - has access to state variable in until loop
- Reward function: combination of victory points, buying power.

== stuff to find out ==
- Does state st have a copy constructor
- Print stuff to the log
- how to take an ai, replace the strategy

== TODO ==
- Matt: Make a function that takes a list of policies, runs k runs of horizon h on each policy and returns the one with the highest average discounted reward
- Matt: Finish rollout for baseline comparason and run examples to get comparason data.
- Andrew: Make a function that takes a policy and parameterized the gain priority list and returns a list of policies with variations on those parameters.
