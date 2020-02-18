from election import count
import random,os

def test_count(n=50, repeat_for=10**7,seed=None):
    random.seed("A" if seed != None else os.environ["SEED"])
    for i in range(repeat_for):
        options = [str(i) for i in range(random.randint(4,20))]
        votes = [random.sample(options,k=random.randint(1,len(options))) for i in range(n)]
        result = count(votes,options)

        # On AV there is one option deleted every round
        # thus after len(options) rounds, AV has to stop.
        assert len(result["rounds"]) <= len(options)
        assert len(result["rounds"]) > 0
        
        assert result["thrown_out"] >= 0

        if result["winner"] != "NoneOfTheOtherOptions":
            assert result["thrown_out"]/len(votes) >= 0.5
        else:
            assert result["thrown_out"] >= 0.5*len(votes)

        
