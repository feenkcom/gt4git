Extension { #name : #IceLibgitFiletreeLog }

{ #category : #'*GToolkit4Git' }
IceLibgitFiletreeLog >> definitionFor: aMethod path: aPath commit: aCommit [
	<gtPharoPatch: #Pharo>
	
	^ ((IceLibgitFiletreeLogReader fileName: aPath on: aCommit)
		package: aMethod package mcPackage;
		packageDirectory: (self repository directoryPathStringForPackage: aMethod package);
		definitions)
		detect: [ :each | 
			each isMethodDefinition
				and: [ each selector = aMethod selector
						and: [ each method isClassSide = aMethod isClassSide ] ] ]
		ifNone: [  "not found, return 'NULL' object: compare will fail anyway"MCMethodDefinition
				className: aMethod origin name
				selector: aMethod selector
				category: #''
				timeStamp: nil
				source: '' ]
]
