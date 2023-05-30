Class {
	#name : #GtGitIceDiff,
	#superclass : #IceDiff,
	#category : #'GToolkit4Git-Model'
}

{ #category : #building }
GtGitIceDiff >> buildForChanges: aCollection [
	"This is a copy of the superclass method that uses GtGitIceChangeImporter instead of IceChangeImporter."
	
	| leftTree rightTree |
	leftTree := IceNode value: IceRootDefinition new.
	rightTree := IceNode value: IceRootDefinition new.

	aCollection do: [ :change | 
		change accept: (GtGitIceChangeImporter new
			version: source;
			diff: self;
			parentNode: leftTree;
			yourself).
			
		change accept: (GtGitIceChangeImporter new
			version: target;
			diff: self;
			parentNode: rightTree;
			yourself) ] "displayingProgress: [ :change | change displayingProgressString ]".

	mergedTree := self mergedTreeOf: leftTree with: rightTree.
	tree := mergedTree select: [ :operation | operation hasChanges ].
]
