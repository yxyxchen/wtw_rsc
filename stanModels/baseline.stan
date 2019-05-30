data {
  // depending on the condition
  real wIni;
  int tMax;
  int nTimeSteps; // nTimeSteps = tMax / stepDuration
  
  // depending on each subject
  int N; // number of trials
  vector[N] timeWaited;
  vector[N] trialEarnings;
  int Ts[N]; // terminal time step index 
}
transformed data {
  // constant
  real stepDuration = 1;
  real iti = 2;
  real tokenValue = 10;
  int totalSteps = sum(Ts) - N;
}
parameters {
  real<lower = 0, upper = 1> waitRate;
}
model {
  waitRate ~ uniform(0, 1);
  // calculate the likelihood 
  for(tIdx in 1 : N){
    int action;
    for(i in 1 :(Ts[tIdx] - 1)){
    if(trialEarnings[tIdx] == 0 && i == (Ts[tIdx] - 1)){
      action = 0; // quit
    }else{
      action = 1; // wait
    }
      target += bernoulli_lpmf(action | waitRate);// theta defines the prob of 1
    } 
  }
}
generated quantities {
// initialize log_lik
  vector[totalSteps] log_lik = rep_vector(0, totalSteps);
  real LL_all;
  int no = 1;
  // loop over trials
  for(tIdx in 1 : N){
    int action;
    for(i in 1 : (Ts[tIdx] - 1)){
      if(trialEarnings[tIdx] == 0 && i == (Ts[tIdx] - 1)){
        action = 0; // quit
      }else{
        action = 1; // wait
      }
      log_lik[no] = bernoulli_lpmf(action | waitRate);
      no = no + 1;
    }
  }// end of the loop
  LL_all =sum(log_lik);
}



