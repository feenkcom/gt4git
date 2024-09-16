Extension { #name : #PureGitFileStatus }

{ #category : #'*GToolkit4Git' }
PureGitFileStatus >> gtStagedChangesFor: composite [
	<gtView>
	^ composite textEditor
		title: 'Staged';
		priority: 30;
		text: [ self stagedChangesAsRopedText ]
]

{ #category : #'*GToolkit4Git' }
PureGitFileStatus >> gtUnstagedChangesFor: composite [
	<gtView>
	^ composite textEditor
		title: 'Staged';
		priority: 30;
		text: [ self unstagedChangesAsRopedText ]
]
