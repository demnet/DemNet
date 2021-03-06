**Moved to: https://gitlab.com/csdummi/demnet**

# Elections using IPFS and a supervisor

## Abstract
I want to introduce a system, that ensures
that all voter's choice is secret and
that everybody can check the tally,
without knowing who voted how.
But to ensure the secrecy we need to
have a trusted party, called the supervisor.
This might be automatized by using a Smart Contract
on a Blockchain, that can access IPFS.
Otherwise the whole Election is decentralized  
and can be validated by anyone who wants to.

## Introduction
I wanted to build a social network,
where every user would have a vote
and could decided upon the future development
of the network.
In the early days this network would be very much like
the Athenian democracy, letting anybody vote on anybody,
but without any such restrictions, as the disenfranchisement
of woman, slaves, children and so forth.
Later there would be a simple parliamentary democracy,
similar to the British or representative, like the Germans.
How and when these later systems would be implemented must have been
the decision of the users, as anything else.
But to properly do this, we would have to have a solid mechanism
for holding Elections, of whichever kind.
In Germany we have 4 principles, that every democratic elections
should hold up:

1. Equal, every vote counts the same ( nobody has more influence than another )
2. Immediate, no intermediates, like with the electoral colleague in the USA.
3. Free, every voter can choose whatever they want and must not expect personal reprisals from their choice.
4. Secrecy, nobody knows how a voter voted.

The proposed system cannot ensure all of these and if the supervisor is not
trustworthy, the whole Election is invalid.
But it can ensure both a free and secret Election, as well as another
side effect, which is that everybody can count the votes ( I would call that
principles checkable or controllable ).

## The Process of an Election

![Process Description](election.png)

Every Election needs a trusted party,
which counts the votes and
administers the Election.
This party cannot take part in the
political process in any other way,
meaning they can't be part of a political party or movement.
Our supervisor initializes an Election by giving each voter a
temporary private key and publishing the public keys on an
IPFS File, which I will call the Public Key Index.

Now each Voter creates and signs, using their
temporary private key, their Vote File on IPFS or abstains,
this can happen privately or through the supervisor.
But perhaps the supervisor could log the traffic and associated certain traffic
with a voter and encrypt the vote using the Public Key Index?
Well, they could do that, but that wouldn't be necessary for the supervisor,
after all, the supervisor has already created and assigned the keys and could
just have kept a copy of the assignment, thus making it an unreal vulnerability.
But this illustrates how important it is that the supervisor is trusted,
because if not, the whole Election cannot be considered valid.

The CID ( Content ID or Hash of the Vote File) of the vote is then added by the
voter, again through an external or the supervisor, to another Index, called
the ballot.
After the deadline for the election is met,
the supervisor or anybody else, who wants to count the ballot,
can do so.

## Counting the results
If you want to count the results, you have to:

1. Download the Ballot File and Public Key Index
2. Download vote files in the ballot
3. Encode vote files and throw out any key used already
4. Count the encoded votes

Anybody can do this because all these files are
public on IPFS.

## Ballot File
The Ballot File isn't a File, like the Vote File.
Because a Vote File or the Public Key Index File,
don't need to change, so you can simply add them
to IPFS and only have to cat them later.
But Ballot File is different as every voter needs
to change it, to cast their vote.
So, we can't use IPFS?
We can, just differently!
The Ballot will now be just a file containing a unique
token containing the deadline, the name, the options ( aye, nay, etc.)
and some random content to make it impossible to overlap with other elections.
Now each vote has two parts:

```
ballot: <hash CID of Ballot File>
vote: <encrypted vote>
```
After that, the voter adds the CID of his vote to the supervisor's
index.
After the deadline passes, the supervisor publishes all CIDs the supervisor
received in a ballot reference index file, which is now immutable
and can be published on IPFS.
This is done, so everyone can check and the election result is transparent.

## Conclusion
With this method you can't associated a vote with a user, because you
don't have the public key, for a user, thus secrecy is ensured.
And check ability is ensured because anything you need to calculate
the results, is public on IPFS.
Again, this process doesn't provide free, equal or immediate
elections and I don't think that this is possible, because all these
principles are part of the execution of the results of the election
and this process can only securely and check able provide the results of an election.
