//
//  MGMovieRecorderDelegate.h
//  MGBaseKit
//
//  Created by Megvii on 2017/4/18.
//  Copyright © 2017Year megvii. All rights reserved.
//

#ifndef MGMovieRecorderDelegate_h
#define MGMovieRecorderDelegate_h

@class MGMovieRecorder;

@protocol MovieRecorderDelegate <NSObject>

@required

- (void)movieRecorderDidFinishPreparing:(MGMovieRecorder *)recorder;
- (void)movieRecorder:(MGMovieRecorder *)recorder didFailWithError:(NSError *)error;
- (void)movieRecorderDidFinishRecording:(MGMovieRecorder *)recorder;

@end

#endif /* MGMovieRecorderDelegate_h */
