Extension { #name : #IceGitCliIndex }

{ #category : #'*GToolkit4Git' }
IceGitCliIndex >> addLepiterDatabase: aDatabaseDefinition [
	self addPath: (RelativePath 
		withAll: aDatabaseDefinition localRootRelativePath)
]

{ #category : #'*GToolkit4Git' }
IceGitCliIndex >> gtViewPathsIn: composite [
	<gtView>
	^ composite list
		title: 'Paths';
		priority: 20;
		items: [ modifiedFilePaths asArray ];
		itemText: #yourself
]
