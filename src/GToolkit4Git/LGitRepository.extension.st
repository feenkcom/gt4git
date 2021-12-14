Extension { #name : #LGitRepository }

{ #category : #'*GToolkit4Git' }
LGitRepository >> diff_index_to_workdir: diff [

	^ self
		  ffiCallSafely: #( LGitReturnCodeEnum git_diff_index_to_workdir
			     #( LGitDiff * diff, self , NULL , NULL ) )
		  options: #(  )
]

{ #category : #'*GToolkit4Git' }
LGitRepository >> diff_num_deltas: diff [

	^ self
		  ffiCallSafely: #( size_t git_diff_num_deltas #( void * diff ) )
		  options: #(  )
]

{ #category : #'*GToolkit4Git' }
LGitRepository >> getDeltas [

	| out numDiffs |
	out := LGitDiff newPointer autoRelease; repository: self.
	self diff_index_to_workdir: out.
	numDiffs := self diff_num_deltas: out.
	
	^ (0 to: numDiffs - 1) collect: [:i | self diff_get_delta: out at: i]
]

{ #category : #'*GToolkit4Git' }
LGitRepository >> isDirty [

	| out numDiffs |
	out := LGitDiff newPointer autoRelease; repository: self.
	self diff_index_to_workdir: out.
	numDiffs := self diff_num_deltas: out.

	^ numDiffs isZero not
]
