Extension { #name : #LGitRepository }

{ #category : #'*GToolkit4Git' }
LGitRepository >> getDeltas [

	| out numDiffs |
	out := LGitDiff newPointer autoRelease; repository: self.
	
	out diffTreeToWorkdir: (self revparse: self head basename) tree inRepo: self.
	
	^ out deltas
]

{ #category : #'*GToolkit4Git' }
LGitRepository >> isDirty [

	| out numDiffs head |
	out := LGitDiff newPointer autoRelease; repository: self.
	head := self head.
	out diffTreeToWorkdir: (self revparse: head name) tree inRepo: self.

	^ out numberOfDeltas isZero not
]

{ #category : #'*GToolkit4Git' }
LGitRepository >> status_list_new: out [ 
	^ self ffiCallSafely: #(int git_status_list_new (LGitStatusList out, self, NULL)) options: #()
]

{ #category : #'*GToolkit4Git' }
LGitRepository >> status_list_new: out withOpts: opts [
	^ self ffiCallSafely: #(int git_status_list_new (LGitStatusList* out, LGitRepository self, LGitStatusOptions* opts)) options: #()
]
