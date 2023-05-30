Extension { #name : #LGitIndex }

{ #category : #'*GToolkit4Git' }
LGitIndex >> index_remove_bypath: index path: path [
	
	^ self
		ffiCallSafely:
			#(LGitReturnCodeEnum git_index_remove_bypath #(self, String path))
		options: #(optMayGC optCoerceNilToNull)
]

{ #category : #'*GToolkit4Git' }
LGitIndex >> index_remove_directory: index dir: path stage: stage [

	^ self
		  ffiCallSafely: #( LGitReturnCodeEnum git_index_remove_directory
			     #( self , String path , int stage ) )
		  options: #( optMayGC optCoerceNilToNull )
]

{ #category : #'*GToolkit4Git' }
LGitIndex >> remove: aString [

	self withReturnHandlerDo: [ 
		self index_remove_bypath: self path: aString ]
]

{ #category : #'*GToolkit4Git' }
LGitIndex >> removeDirectory: aString [

	self withReturnHandlerDo: [ 
		self index_remove_directory: self dir: aString stage: 0 ]
]
