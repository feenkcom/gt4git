Extension { #name : #LGitStatusList }

{ #category : #'*GToolkit4Git' }
LGitStatusList >> at: idx [
	^ self ffiCallSafely: #(LGitStatusEntry git_status_byindex(self, size_t idx)) options: #()
]

{ #category : #'*GToolkit4Git' }
LGitStatusList >> gtInfoFor: aView [
	<gtView>
	^ ({
		#Size -> self size
	} asOrderedDictionary gtItemsFor: aView)
			title: 'Info';
			priority: 7
]

{ #category : #'*GToolkit4Git' }
LGitStatusList >> size [

	^ self
		  ffiCallSafely: #( size_t git_status_list_entrycount
		     #( self ) )
		  options: #(  )
]
