Extension { #name : #LGitRepository }

{ #category : #'*GToolkit4Git' }
LGitRepository >> getDeltasFromHead: aHead [
	^ self getDeltasFromHead: aHead options: LGitDiffOptions defaults
]

{ #category : #'*GToolkit4Git' }
LGitRepository >> getDeltasFromHead: aHead options: anLGitDiffOptions [

	| out |
	out := LGitDiff newPointer autoRelease; repository: self.
	
	out 
		diffTreeToWorkdir: (self revparse: aHead gitRef) tree 
		inRepo: self
		options: anLGitDiffOptions.
	
	^ out deltas
]

{ #category : #'*GToolkit4Git' }
LGitRepository >> isDirty [

	| out head |
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
