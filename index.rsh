'reach 0.1';

const [isOutcome, B_WINS, DRAW, A_WINS ] = makeEnum(3);

const winner = (fingerAlice, fingerBob, guessAlice, guessBob) => {
  // If Both player's guessing is same then draw
  if(guessAlice == guessBob){
    return DRAW;
  }else{//Both player's guessing is not same
    if(fingerAlice+fingerBob == guessAlice){ //Alice's guess is correct
      return A_WINS;
    }else{
      if(fingerAlice+fingerBob == guessBob){//Bob's guess is correct
        return B_WINS;
      }else{
        return DRAW; // Both player's guess is incorrect then draw
      }
    }
  }
}

assert(winner(3, 3, 5, 6) == B_WINS);// Bob's guess is correct
assert(winner(1, 2, 3, 2) == A_WINS);//Alice's guess is correct
assert(winner(1, 3, 5, 5) == DRAW);//Both's guess is same
assert(winner(1, 3, 1, 6) == DRAW);//Both's guess is incorrect

forall(UInt, fingerAlice =>
  forall(UInt, fingerBob =>
    forall(UInt, guessAlice =>
      forall(UInt, guessBob =>
        assert(isOutcome(winner(fingerAlice, fingerBob,guessAlice,guessBob)))))));

forall(UInt, (fingerAlice) =>
  forall(UInt, (fingerBob) =>       
    forall(UInt, (guess) =>
      assert(winner(fingerAlice, fingerBob, guess, guess) == DRAW))));   


const Player = {
  ...hasRandom,
  getFinger: Fun([], UInt),
  getGuess: Fun([], UInt),
  seeOutcome: Fun([UInt], Null),
  informTimeout: Fun([], Null),
};

export const main = Reach.App(() => {
  const Alice = Participant('Alice', {
    ...Player,// Specify Alice's interact interface here
    wager: UInt,
    deadline: UInt,
  });
  const Bob = Participant('Bob', {
    ...Player,// Specify Bob's interact interface here
    acceptWager: Fun([UInt], Null),
  });
  init();//move into step

  const informTimeout = () => {
    each([Alice, Bob], () => { 
      interact.informTimeout();
    });
  };
  
  // The first one to publish deploys the contract
  Alice.only(()=>{ //move to Alice local step
    const amount = declassify(interact.wager); // Accpet wager from frontend
    const deadline = declassify(interact.deadline);
  });

  Alice.publish(amount, deadline)// publish &pay move to consensus step
  .pay(amount);//Transfer the amount into the contact
  commit();//Back to Step

  // The second one to publish always attaches
  Bob.only(()=>{
    interact.acceptWager(amount);
  });

  Bob.pay(amount)
  .timeout(relativeTime(deadline), () => closeTo(Alice, informTimeout));

  // write your program here
  var outcome = DRAW;
  invariant(balance() == 2 * amount && isOutcome(outcome) );//balance will notgoing to change and isOutcome have some value passing by parameter
  
  while(outcome == DRAW){ // looping to until get a winner
    commit(); //Undone consensus step and back to step
    Alice.only(()=>{
      const _fingerAlice = interact.getFinger(); // Keep the value in secret 
      const _guessAlice = interact.getGuess();
      
      const [_commitAlice, _saltAlice] = makeCommitment(interact, _fingerAlice);
      const commitAlice = declassify(_commitAlice); // declassify Alice's conmmit but not any infomation that can affect the game
      const [_commitGuessAlice, _saltGuessAlice] = makeCommitment(interact, _guessAlice);
      const commitGuessAlice = declassify(_commitGuessAlice);
    });
    Alice.publish(commitAlice, commitGuessAlice) //Publish the commitment
    .timeout(relativeTime(deadline), () => closeTo(Bob, informTimeout));// This will make Alice need to answer before deadline if not the system will inform Bob
    commit();

    //Make sure that Bob will not know the amount of finger of Alice and the salt that contain Alice's info
    unknowable(Bob, Alice(_fingerAlice, _saltAlice));
    //Make sure that Bob will not know the Alice's guess and the salt that contain this info
    unknowable(Bob, Alice(_guessAlice, _saltGuessAlice));

    Bob.only(()=>{
      // const _fingerBob = interact.getFinger();
      // const _guessBob = interact.getGuess();

      const fingerBob = declassify(interact.getFinger());
      const guessBob = declassify(interact.getGuess());
    });
    Bob.publish(fingerBob, guessBob)
    .timeout(relativeTime(deadline), () => closeTo(Alice, informTimeout));

    commit();

    //Alice will declassify all the info that she hide
    Alice.only(()=>{
      const [saltAlice, fingerAlice] = declassify([_saltAlice, _fingerAlice]);
      const [saltGuessAlice, guessAlice] = declassify([_saltGuessAlice, _guessAlice]);
    });
    Alice.publish(saltAlice, fingerAlice, saltGuessAlice, guessAlice)
    .timeout(relativeTime(deadline), () => closeTo(Bob, informTimeout));// This will make Alice need to answer before deadline if not the system will inform Bob

    //Check whether the value of salt, fingerAlice and guessAlice is differ from the commitment 
    checkCommitment(commitAlice, saltAlice, fingerAlice);
    checkCommitment(commitGuessAlice, saltGuessAlice, guessAlice);

    //Get a winner and it's DRAW then the loop will be continue.
    outcome = winner(fingerAlice, fingerBob, guessAlice, guessBob);
    continue;
  }

  assert(outcome == A_WINS || outcome == B_WINS);
  transfer(2 * amount).to(outcome == A_WINS ? Alice: Bob);
  commit();
  each([Alice, Bob], () => {
    interact.seeOutcome(outcome); })
  exit(); 
});