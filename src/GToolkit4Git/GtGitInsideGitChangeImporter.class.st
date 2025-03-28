Class {
	#name : #GtGitInsideGitChangeImporter,
	#superclass : #IceGitChangeImporter,
	#category : #'GToolkit4Git-Model'
}

{ #category : #importing }
GtGitInsideGitChangeImporter >> ensureLepiterDatabaseFromDirectory: fileReference inParentNode: aNode [ 
	self shouldBeImplemented.
]

{ #category : #importing }
GtGitInsideGitChangeImporter >> importOn: aNode [
	"This is a copy of the method in the superclass "
	| currentSegment fileReference filePath |
	currentSegment := path segments first.
	
	filePath := aNode path / currentSegment.
	fileReference := version fileSystem resolve: filePath.
		
	"Do not import if the file does not exist in git"
	fileReference exists
		ifFalse: [ ^ self ].

	"If I represent a package, let's do it and do nothing else.
	This could be optimized to add the exact methods and avoid MC diff afterwards"
	((diff isCodeSubdirectory: aNode)
		and: [ version writerClass isValidPackage: fileReference ])
			ifTrue: [ ^ self ensurePackageFromDirectory: fileReference inParentNode: aNode ].
	
	"-------"
	(self isLepiterDatabaseSubdirectory: fileReference)
			ifTrue: [ ^ self 
				ensureLepiterDatabaseFromDirectory: fileReference 
				inParentNode: aNode ].
	"-------"

	"If I do not represent a package, I may be a file or a directory that may (recursively) contain a method or a package.
	For now, we only support packages inside the declared subdirectory (or root otherwise).
	All other changes are simple directory/file changes"
	
	"If path = 1 this means it is a file"
	path size = 1
		ifTrue: [ 
				fileReference exists ifTrue: [
				^ aNode addChild: (IceFileDefinition named: currentSegment path: filePath fileReference: fileReference) ] ].
	
	path size > 1 ifTrue: [ | directoryReference directoryPath |
		directoryPath := aNode path / currentSegment.
		directoryReference := version fileSystem resolve: directoryPath.
			directoryReference exists ifTrue: [
				"Otherwise, we recursively create a directory structure"
				self nextPath importOn: (self ensureDirectory: fileReference inParentNode: aNode) ] ].
	
	"If path size = 0 we should stop recursion"
]

{ #category : #importing }
GtGitInsideGitChangeImporter >> isLepiterDatabaseSubdirectory: aFileReference [ 
	^ aFileReference isDirectory and: [ 
		aFileReference files anySatisfy: [ :aFile |
			aFile basename = LepiterCoreDefaults databasePropertiesBasename] ]
]
