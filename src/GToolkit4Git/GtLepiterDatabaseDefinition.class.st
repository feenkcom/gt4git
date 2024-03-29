Class {
	#name : #GtLepiterDatabaseDefinition,
	#superclass : #GtLepiterDefinition,
	#instVars : [
		'databaseId',
		'localRootRelativePath'
	],
	#category : #'GToolkit4Git-Lepiter'
}

{ #category : #visiting }
GtLepiterDatabaseDefinition >> accept: aVisitor [
	
	^ aVisitor visitLepiterDatabase: self
]

{ #category : #accessing }
GtLepiterDatabaseDefinition >> canBeBrowsed [
	^ true
]

{ #category : #accessing }
GtLepiterDatabaseDefinition >> databaseFolderName [

	^ self localRootRelativePath basename
]

{ #category : #accessing }
GtLepiterDatabaseDefinition >> databaseId [

	^ databaseId
]

{ #category : #accessing }
GtLepiterDatabaseDefinition >> databaseId: anObject [

	databaseId := anObject
]

{ #category : #accessing }
GtLepiterDatabaseDefinition >> icon [
	^ LeIcons lepiterDatabase create asSpartaForm
]

{ #category : #accessing }
GtLepiterDatabaseDefinition >> key [
	"The key is used by {{gtClass:IceNode}} to compute the path, so we use the
	folder name. Because of that it should be a single folder."
	
	^ self databaseFolderName
]

{ #category : #accessing }
GtLepiterDatabaseDefinition >> localRootRelativePath [
	^ localRootRelativePath
]

{ #category : #accessing }
GtLepiterDatabaseDefinition >> localRootRelativePath: aPath [
	localRootRelativePath := aPath
]

{ #category : #printing }
GtLepiterDatabaseDefinition >> printOn: aStream [
	super printOn: aStream.
	aStream 
		<< '(';
		<< self name;
		<< ', ';
		<< self databaseId asString36;
		<< ')'
]

{ #category : #accessing }
GtLepiterDatabaseDefinition >> toolIn: aGtRepository [
	| targetDatabase |
	targetDatabase := aGtRepository lepiterWorkingCopy databases 
		detect: [ :aDatabase | aDatabase uuid = self databaseId ].
	^ targetDatabase asPhlowTool
]
