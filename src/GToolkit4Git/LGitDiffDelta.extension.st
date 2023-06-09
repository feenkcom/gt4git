Extension { #name : #LGitDiffDelta }

{ #category : #'*GToolkit4Git' }
LGitDiffDelta >> gtInfoFor: aView [
	<gtView>
	
	^ ({
		#Status -> self status.
		#NewFile -> (self newFile printString, '; Path: ', self newFile path).
		#OldFile -> (self oldFile printString, '; Path: ', self oldFile path).
		#NumberOfFiles -> self numberOfFiles.
	} asOrderedDictionary  gtItemsFor: aView)
			title: 'Info';
			priority: 3
]

{ #category : #'*GToolkit4Git' }
LGitDiffDelta >> icon [

	^ self status icon
]
