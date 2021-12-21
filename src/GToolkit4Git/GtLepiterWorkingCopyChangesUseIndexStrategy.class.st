Class {
	#name : #GtLepiterWorkingCopyChangesUseIndexStrategy,
	#superclass : #GtLepiterWorkingCopyChangesStrategy,
	#category : #'GToolkit4Git-Lepiter'
}

{ #category : #'API - changes' }
GtLepiterWorkingCopyChangesUseIndexStrategy >> changesTo: aCommitish [
	| changedDatabases |
	
	changedDatabases := OrderedDictionary new.
	self workingCopy repository getDeltas do: [ :delta | 
		| path |
		path := delta oldFile path.
		"TODO ignore properties and attachment files for now"
		(path basename = LepiterCoreDefaults databasePropertiesBasename or: [ 
			 path parent parent basename = 'attachments' ]) ifFalse: [ 
			self workingCopy databases
				detect: [ :db | db localStoreRootDirectory asPath = path parent ]
				ifFound: [ :database | 
					changedDatabases
						at: database
						update: [ :aList | aList , { delta } ]
						initial: { delta } ] ] ].
		
	^ changedDatabases keys collect: [ :key | 
		  GtLepiterLocalDatabaseChange new
			  database: key;
			  pages: (changedDatabases at: key) ]
]
