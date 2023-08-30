# This file document some potential future work plans

## Exploration
1. Try out different model and optimize it for mobile with latest version of pytorch (involves in compiling latest pytorch library for iOS )
2. Pytorch mobile is considered poorly documented, and development efforts by facebook seems have paused. So can we use another framework like tensorflow lite and CoreML to do the same (Main objective is to see the amount of documentation and community support)

## Work Division
 The bulk of work for this app can be achieved using react native including UI, speech synthesis, etc. This can be stated as soon as we have features finalized. 
 Customizable advanced features like speech recognition can be divided into two areas: technical involving with Obj-C and Swift, and machine learning that focus on quantization of the model for mobile devices.