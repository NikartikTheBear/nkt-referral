# nkt-referral
Simple and light referral system for fiveM
This resource assigns a referral code to each player that they can share, if a user inputs another users referral code they both get a reward
- Each user may use a single referral code
- You may setup special referral codes that give out different rewards (like streamer, ccs codes)
- You may setup special promo codes that are not tied to a particular player, they still can be used only one time (just wipe it from the db if you wish to reuse one)


### Dependencies
- Ox-Lib

### Setup codes
**IMPORTANT** Always put the reward/promo codes in caps!

```lua
--server/rewards.lua

Rewards = {
  ["default"] = function(id) --always leave the "default" code, is the default reward given out if no special code is found
     --id is the server id of the user who reclaims the code and the code owner server id
     --your reward code
  end,
  ["MYPROMOCODE"] = { --this is the format for a promo code, only set it up like this for a promo code
    isPromo = true, 
    action = function(id)
     --id is the server id of the user who reclaims the code
     --your reward code
    end,
  },
  ["STREAMERXXX"] = function(id) 
    --You may specifiy a user referral code to give out a particular reward, this overrides the defaults reward
  end,
}

```

if you wish to reset a player code just wipe their row from the database, it will automatically get regenerated.
if you wish to reset a promo code use just wipe the respective row from the db and leave the code in the rewards table, it will automatically get regenerated.

if you have questions just hit me up on [Discord](https://discord.gg/SHXVdCG7Qg)

feel free to point out any errors or problems/improvements
