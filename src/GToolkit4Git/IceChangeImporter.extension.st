Extension { #name : #IceChangeImporter }

{ #category : #'*GToolkit4Git' }
IceChangeImporter >> visitLepiterDatabaseChange: aLepiterDatabaseChange [

	| importer |
	importer := GtGitLepiterDatabaseChangeImporter new
		lepiterDatabaseChange: aLepiterDatabaseChange;
		version: version;
		yourself.
	^ importer importOn: parentNode
]
