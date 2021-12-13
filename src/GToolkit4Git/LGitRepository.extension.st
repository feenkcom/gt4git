Extension { #name : #LGitRepository }

{ #category : #'*GToolkit4Git' }
LGitRepository >> diff_free: out [
	self ffiCallSafely: #(void git_diff_free ( void * out)) options: #()
]

{ #category : #'*GToolkit4Git' }
LGitRepository >> diff_index_to_workdir: diff [

	^ self
		  ffiCallSafely: #( LGitReturnCodeEnum git_diff_index_to_workdir
			     #( void ** diff, self , NULL , NULL ) )
		  options: #(  )
]

{ #category : #'*GToolkit4Git' }
LGitRepository >> isDirty [

	| out numDiffs |
	out := ExternalAddress newPointer.
	self diff_index_to_workdir: out.
	numDiffs := self diff_num_deltas: out.
	self diff_free: out.
	^ numDiffs isZero not
]
