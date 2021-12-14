Extension { #name : #LGitDiffDelta }

{ #category : #'*GToolkit4Git' }
LGitDiffDelta >> gtInfoFor: aView [
	<gtView>
	
	^ ({
		#Status -> self status.
		#NewFile -> self newFile.
		#OldFile -> self oldFile.
		#NumberOfFiles -> self numberOfFiles.
	} asOrderedDictionary  gtItemsFor: aView)
			title: 'Info';
			priority: 3
]
