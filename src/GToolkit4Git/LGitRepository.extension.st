Extension { #name : #LGitRepository }

{ #category : #'*GToolkit4Git' }
LGitRepository >> getDeltasFromHead: aHead options: anLGitDiffOptions into: aDiffPointer [

	| tree |
	
	tree := aHead treeFor: self.
	
	aDiffPointer 
		diffTreeToWorkdir: tree 
		inRepo: self
		options: anLGitDiffOptions.
	
	^ aDiffPointer deltas
]

{ #category : #'*GToolkit4Git' }
LGitRepository >> isDirty [

	| out head res |
	out := LGitDiff of: self.
	head := self head.
	out diffTreeToWorkdir: (self revparse: head name) tree inRepo: self.

	res := out numberOfDeltas isZero not.
	out free.
	^ res
]

{ #category : #'*GToolkit4Git' }
LGitRepository >> status_list_new: out [ 
	^ self ffiCallSafely: #(int git_status_list_new (LGitStatusList out, self, NULL)) options: #()
]

{ #category : #'*GToolkit4Git' }
LGitRepository >> status_list_new: out withOpts: opts [
	^ self ffiCallSafely: #(int git_status_list_new (LGitStatusList* out, LGitRepository self, LGitStatusOptions* opts)) options: #()
]
